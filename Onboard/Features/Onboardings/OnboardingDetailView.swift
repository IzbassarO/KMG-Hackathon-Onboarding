import SwiftUI
import SwiftData

struct OnboardingDetailView: View {
    @Bindable var onboarding: Onboarding
    @Environment(\.modelContext) private var context

    @State private var editingStage: OnboardingStage?
    @State private var pendingDeleteStage: OnboardingStage?
    @State private var connectMode = false
    @State private var connectSource: OnboardingStage?
    @State private var isEditingEmployee = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                header
                raiseTicketBar
                trackerCanvas
                ticketList
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Theme.Surface.base)
        .navigationTitle(onboarding.employee?.fullName ?? "Onboarding")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { raiseTicket() } label: { Label("Raise ticket", systemImage: "plus") }
                    Button {
                        connectMode.toggle()
                        connectSource = nil
                    } label: {
                        Label(connectMode ? "Exit connect mode" : "Connect tickets", systemImage: "link")
                    }
                    Button { isEditingEmployee = true } label: {
                        Label("Edit employee", systemImage: "person.crop.circle.badge.pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $editingStage) { stage in
            OnboardingStageEditorSheet(
                stage: stage,
                onSave: { try? context.save() },
                onDelete: {
                    editingStage = nil
                    DispatchQueue.main.async { delete(stage) }
                }
            )
        }
        .sheet(isPresented: $isEditingEmployee) {
            if let employee = onboarding.employee {
                EmployeeEditorSheet(employee: employee, onSave: { try? context.save() })
            }
        }
        .alert("Delete this ticket?", isPresented: deleteAlertBinding) {
            Button("Delete", role: .destructive) {
                if let stage = pendingDeleteStage { delete(stage) }
                pendingDeleteStage = nil
            }
            Button("Cancel", role: .cancel) { pendingDeleteStage = nil }
        }
        .onChange(of: connectMode) { _, newValue in
            if !newValue { connectSource = nil }
        }
    }

    // MARK: - Header

    private var header: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                HStack(spacing: Theme.Spacing.l) {
                    Avatar(name: onboarding.employee?.fullName ?? "?", diameter: 60)
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(onboarding.employee?.position ?? "—")
                            .font(Theme.Font.headline)
                            .foregroundStyle(Theme.Ink.primary)
                        Text(onboarding.employee?.department ?? "—")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Ink.secondary)
                        Text(onboarding.employee?.location ?? "—")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Ink.secondary)
                    }
                    Spacer()
                    ProgressRing(
                        progress: onboarding.progress,
                        tint: onboarding.isFullyComplete ? Theme.success : Theme.Brand.primary,
                        diameter: 64
                    )
                }

                HStack(spacing: Theme.Spacing.s) {
                    Pill(onboarding.templateName, systemImage: "rectangle.connected.to.line.below",
                         tint: Theme.Brand.primary)
                    if let countdown = onboarding.employee?.startCountdown {
                        Pill(countdown, systemImage: "calendar")
                    }
                    Pill("\(onboarding.completedStages)/\(onboarding.totalStages) done",
                         systemImage: "checkmark.circle", tint: Theme.success)
                }

                if let employee = onboarding.employee, !employee.contractNumber.isEmpty {
                    HStack(spacing: Theme.Spacing.s) {
                        Pill(employee.contractType, systemImage: "doc.text", tint: Theme.info)
                        Pill(employee.contractNumber, systemImage: "number")
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.l)
    }

    private var raiseTicketBar: some View {
        Button { raiseTicket() } label: {
            Label("Raise ticket", systemImage: "plus.circle.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, Theme.Spacing.l)
    }

    // MARK: - Canvas

    private var trackerCanvas: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            SectionHeader("Flowchart",
                          subtitle: connectMode
                            ? (connectSource == nil ? "Tap the source ticket" : "Tap the destination ticket")
                            : "Tap a ticket to open and update it.",
                          systemImage: "scribble.variable")
                .padding(.horizontal, Theme.Spacing.l)

            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    CanvasGrid()
                    ConnectionLayer(nodes: nodes, edges: edges)
                    ForEach(onboarding.stages) { stage in
                        FlowNodeView(
                            node: snapshot(of: stage),
                            isConnectSource: connectSource?.id == stage.id,
                            isConnectTarget: connectMode && connectSource != nil && connectSource?.id != stage.id
                        )
                        .position(x: stage.positionX, y: stage.positionY)
                        .gesture(dragGesture(for: stage))
                        .onTapGesture { handleTap(on: stage) }
                        .contextMenu {
                            Button { stage.advanceStatus(); try? context.save() } label: {
                                Label("Advance status", systemImage: "arrow.right.circle")
                            }
                            Button { editingStage = stage } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                            Button(role: .destructive) {
                                pendingDeleteStage = stage
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .frame(width: CanvasMetrics.canvasSize.width, height: CanvasMetrics.canvasSize.height)
                .coordinateSpace(name: CanvasMetrics.coordinateSpace)
            }
            .frame(height: 420)
            .background(Theme.Surface.elevated)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Theme.Surface.separator, lineWidth: 0.5)
            )
            .padding(.horizontal, Theme.Spacing.l)
        }
    }

    // MARK: - Ticket list

    private var ticketList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            SectionHeader("Tickets",
                          subtitle: "Tap the status icon to advance, or the row to edit.",
                          systemImage: "list.bullet.indent")
                .padding(.horizontal, Theme.Spacing.l)

            ForEach(orderedStages) { stage in
                TicketRow(
                    stage: stage,
                    onCycleStatus: { stage.advanceStatus(); try? context.save() },
                    onOpen: { editingStage = stage }
                )
                .padding(.horizontal, Theme.Spacing.l)
            }

            if onboarding.stages.isEmpty {
                Text("No tickets yet. Tap “Raise ticket” to add one.")
                    .font(Theme.Font.callout)
                    .foregroundStyle(Theme.Ink.secondary)
                    .padding(.horizontal, Theme.Spacing.l)
            }
        }
    }

    private var orderedStages: [OnboardingStage] {
        onboarding.stages.sorted { lhs, rhs in
            if lhs.positionY != rhs.positionY { return lhs.positionY < rhs.positionY }
            return lhs.positionX < rhs.positionX
        }
    }

    // MARK: - Snapshots

    private var nodes: [FlowNode] {
        onboarding.stages.map(snapshot(of:))
    }

    private var edges: [FlowEdge] {
        onboarding.links.map { FlowEdge(id: $0.id, fromID: $0.fromStageID, toID: $0.toStageID) }
    }

    private func snapshot(of stage: OnboardingStage) -> FlowNode {
        FlowNode(
            id: stage.id,
            title: stage.title,
            owner: stage.owner,
            notes: stage.notes,
            priority: stage.priority,
            status: stage.status,
            position: CGPoint(x: stage.positionX, y: stage.positionY)
        )
    }

    // MARK: - Gestures & actions

    private func dragGesture(for stage: OnboardingStage) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named(CanvasMetrics.coordinateSpace))
            .onChanged { value in
                guard !connectMode else { return }
                stage.positionX = clamp(value.location.x, lower: FlowNode.nodeSize.width / 2,
                                        upper: CanvasMetrics.canvasSize.width - FlowNode.nodeSize.width / 2)
                stage.positionY = clamp(value.location.y, lower: FlowNode.nodeSize.height / 2,
                                        upper: CanvasMetrics.canvasSize.height - FlowNode.nodeSize.height / 2)
            }
            .onEnded { _ in try? context.save() }
    }

    private func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

    private func handleTap(on stage: OnboardingStage) {
        if connectMode {
            if let source = connectSource {
                if source.id == stage.id {
                    connectSource = nil
                } else {
                    addLink(from: source, to: stage)
                    connectSource = nil
                }
            } else {
                connectSource = stage
            }
        } else {
            editingStage = stage
        }
    }

    private func raiseTicket() {
        let placement = nextPlacement()
        let stage = OnboardingStage(
            title: "New ticket",
            status: .open,
            positionX: placement.x,
            positionY: placement.y,
            onboarding: onboarding
        )
        onboarding.stages.append(stage)
        context.insert(stage)
        try? context.save()
        editingStage = stage
    }

    private func nextPlacement() -> CGPoint {
        guard let lowest = onboarding.stages.max(by: { $0.positionY < $1.positionY }) else {
            return CGPoint(x: 220, y: 200)
        }
        return CGPoint(x: lowest.positionX,
                       y: min(lowest.positionY + 140,
                              CanvasMetrics.canvasSize.height - FlowNode.nodeSize.height))
    }

    private func addLink(from source: OnboardingStage, to destination: OnboardingStage) {
        let alreadyExists = onboarding.links.contains { $0.fromStageID == source.id && $0.toStageID == destination.id }
        if alreadyExists {
            onboarding.links.removeAll { $0.fromStageID == source.id && $0.toStageID == destination.id }
        } else {
            let link = OnboardingLink(fromStageID: source.id, toStageID: destination.id, onboarding: onboarding)
            onboarding.links.append(link)
            context.insert(link)
        }
        try? context.save()
    }

    private func delete(_ stage: OnboardingStage) {
        onboarding.links.removeAll { $0.fromStageID == stage.id || $0.toStageID == stage.id }
        onboarding.stages.removeAll { $0.id == stage.id }
        context.delete(stage)
        try? context.save()
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDeleteStage != nil },
            set: { if !$0 { pendingDeleteStage = nil } }
        )
    }
}

private struct TicketRow: View {
    var stage: OnboardingStage
    var onCycleStatus: () -> Void
    var onOpen: () -> Void

    var body: some View {
        Card(padding: Theme.Spacing.m) {
            HStack(spacing: Theme.Spacing.m) {
                Button(action: onCycleStatus) {
                    Image(systemName: stage.status.systemImage)
                        .font(.title3)
                        .foregroundStyle(Theme.tint(for: stage.status))
                }
                .buttonStyle(.plain)

                Button(action: onOpen) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stage.title)
                            .font(Theme.Font.callout.weight(.medium))
                            .foregroundStyle(Theme.Ink.primary)
                            .strikethrough(stage.isCompleted)
                        HStack(spacing: Theme.Spacing.s) {
                            if !stage.owner.isEmpty {
                                Text(stage.owner)
                                    .font(Theme.Font.caption)
                                    .foregroundStyle(Theme.Ink.secondary)
                            }
                            Text(stage.status.displayName)
                                .font(Theme.Font.caption.weight(.semibold))
                                .foregroundStyle(Theme.tint(for: stage.status))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                PriorityDot(priority: stage.priority)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Theme.Ink.secondary)
            }
        }
    }
}

#Preview {
    let container = ModelContainerFactory.makePreview()
    let context = container.mainContext
    let template = (try? context.fetch(FetchDescriptor<Template>()))?.first ?? Template(name: "Demo")
    let employee = Employee(fullName: "Preview Person", position: "Driller",
                            department: "Upstream", location: "Atyrau")
    let onboarding = OnboardingFactory.make(from: template, employee: employee, context: context)
    return NavigationStack {
        OnboardingDetailView(onboarding: onboarding)
    }
    .modelContainer(container)
}
