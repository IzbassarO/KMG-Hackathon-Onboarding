import SwiftUI
import SwiftData

/// Free-form canvas editor for a `Template`'s flowchart. Supports adding,
/// moving, editing, deleting nodes and drawing/removing directed connections.
struct FlowchartBuilderView: View {
    @Bindable var template: Template
    @Environment(\.modelContext) private var context

    @State private var connectMode = false
    @State private var connectSource: TemplateStage?
    @State private var editingStage: TemplateStage?
    @State private var pendingDeleteStage: TemplateStage?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    CanvasGrid()

                    ConnectionLayer(nodes: nodes, edges: edges)

                    ForEach(template.stages) { stage in
                        FlowNodeView(
                            node: snapshot(of: stage),
                            isConnectSource: connectSource?.id == stage.id,
                            isConnectTarget: connectMode && connectSource != nil && connectSource?.id != stage.id
                        )
                        .position(x: stage.positionX, y: stage.positionY)
                        .gesture(dragGesture(for: stage))
                        .onTapGesture { handleTap(on: stage) }
                        .contextMenu {
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
                .frame(width: CanvasMetrics.canvasSize.width,
                       height: CanvasMetrics.canvasSize.height)
                .coordinateSpace(name: CanvasMetrics.coordinateSpace)
            }
            .background(Theme.Surface.base)

            toolbar
                .padding(Theme.Spacing.l)
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { addStage() } label: {
                        Label("Add ticket", systemImage: "plus")
                    }
                    Button {
                        connectMode.toggle()
                        connectSource = nil
                    } label: {
                        Label(connectMode ? "Exit connect mode" : "Connect tickets",
                              systemImage: "link")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $editingStage) { stage in
            StageEditorSheet(stage: stage) {
                try? context.save()
            }
        }
        .alert("Delete this ticket?", isPresented: deleteAlertBinding) {
            Button("Delete", role: .destructive) {
                if let stage = pendingDeleteStage { delete(stage) }
                pendingDeleteStage = nil
            }
            Button("Cancel", role: .cancel) { pendingDeleteStage = nil }
        } message: {
            Text("Connections involving this ticket will also be removed.")
        }
        .onChange(of: connectMode) { _, newValue in
            if !newValue { connectSource = nil }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.s) {
            if connectMode {
                Text(connectSource == nil ? "Tap the source ticket" : "Tap the destination ticket")
                    .font(Theme.Font.caption.weight(.semibold))
                    .padding(.horizontal, Theme.Spacing.m)
                    .padding(.vertical, Theme.Spacing.s)
                    .background(Theme.Brand.primaryDeep, in: Capsule())
                    .foregroundStyle(.white)
            }
            FloatingButton(systemImage: connectMode ? "link.circle.fill" : "link",
                           tint: connectMode ? Theme.Brand.accent : Theme.Brand.primary) {
                connectMode.toggle()
                connectSource = nil
            }
            FloatingButton(systemImage: "plus", tint: Theme.Brand.primary, action: addStage)
        }
    }

    // MARK: - Snapshots

    private var nodes: [FlowNode] {
        template.stages.map(snapshot(of:))
    }

    private var edges: [FlowEdge] {
        template.links.map { FlowEdge(id: $0.id, fromID: $0.fromStageID, toID: $0.toStageID) }
    }

    private func snapshot(of stage: TemplateStage) -> FlowNode {
        FlowNode(
            id: stage.id,
            title: stage.title,
            owner: stage.owner,
            notes: stage.notes,
            priority: stage.priority,
            status: nil,
            position: CGPoint(x: stage.positionX, y: stage.positionY)
        )
    }

    // MARK: - Gestures

    private func dragGesture(for stage: TemplateStage) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named(CanvasMetrics.coordinateSpace))
            .onChanged { value in
                guard !connectMode else { return }
                stage.positionX = clamp(value.location.x, lower: FlowNode.nodeSize.width / 2,
                                        upper: CanvasMetrics.canvasSize.width - FlowNode.nodeSize.width / 2)
                stage.positionY = clamp(value.location.y, lower: FlowNode.nodeSize.height / 2,
                                        upper: CanvasMetrics.canvasSize.height - FlowNode.nodeSize.height / 2)
            }
            .onEnded { _ in
                try? context.save()
            }
    }

    private func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

    // MARK: - Actions

    private func handleTap(on stage: TemplateStage) {
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

    private func addStage() {
        let placement = nextPlacement()
        let stage = TemplateStage(
            title: "New ticket",
            owner: "",
            positionX: placement.x,
            positionY: placement.y,
            template: template
        )
        template.stages.append(stage)
        context.insert(stage)
        try? context.save()
        editingStage = stage
    }

    private func nextPlacement() -> CGPoint {
        guard let lowest = template.stages.max(by: { $0.positionY < $1.positionY }) else {
            return CGPoint(x: 220, y: 200)
        }
        return CGPoint(x: lowest.positionX,
                       y: min(lowest.positionY + 140,
                              CanvasMetrics.canvasSize.height - FlowNode.nodeSize.height))
    }

    private func addLink(from source: TemplateStage, to destination: TemplateStage) {
        let alreadyExists = template.links.contains { $0.fromStageID == source.id && $0.toStageID == destination.id }
        if alreadyExists {
            template.links.removeAll { $0.fromStageID == source.id && $0.toStageID == destination.id }
        } else {
            let link = TemplateLink(fromStageID: source.id, toStageID: destination.id, template: template)
            template.links.append(link)
            context.insert(link)
        }
        try? context.save()
    }

    private func delete(_ stage: TemplateStage) {
        template.links.removeAll { $0.fromStageID == stage.id || $0.toStageID == stage.id }
        template.stages.removeAll { $0.id == stage.id }
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

struct FloatingButton: View {
    var systemImage: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(tint, in: Circle())
                .shadow(color: tint.opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let container = ModelContainerFactory.makePreview()
    let template = (try? container.mainContext.fetch(FetchDescriptor<Template>()))?.first
        ?? Template(name: "Preview")
    return NavigationStack {
        FlowchartBuilderView(template: template)
    }
    .modelContainer(container)
}
