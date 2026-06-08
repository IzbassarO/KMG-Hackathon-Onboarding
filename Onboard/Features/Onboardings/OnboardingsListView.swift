import SwiftUI
import SwiftData

struct OnboardingsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Onboarding.createdAt, order: .reverse) private var onboardings: [Onboarding]
    @Query(sort: \Template.createdAt, order: .reverse) private var templates: [Template]

    @State private var isShowingNew = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    header

                    if onboardings.isEmpty {
                        emptyState
                    } else {
                        statRow

                        LazyVStack(spacing: Theme.Spacing.m) {
                            ForEach(onboardings) { onboarding in
                                NavigationLink(value: onboarding) {
                                    OnboardingRow(onboarding: onboarding)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) { delete(onboarding) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.l)
            }
            .background(Theme.Surface.base)
            .navigationTitle("Onboardings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { isShowingNew = true } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(templates.isEmpty)
                }
            }
            .navigationDestination(for: Onboarding.self) { onboarding in
                OnboardingDetailView(onboarding: onboarding)
            }
            .sheet(isPresented: $isShowingNew) {
                NewOnboardingSheet(templates: templates)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("People in flight")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.Ink.primary)
            Text("Track every new hire stage by stage. Tap to open and check off completed steps.")
                .font(Theme.Font.callout)
                .foregroundStyle(Theme.Ink.secondary)
        }
    }

    private var statRow: some View {
        HStack(spacing: Theme.Spacing.m) {
            StatCapsule(value: "\(activeCount)", label: "Active", tint: Theme.Brand.primary)
            StatCapsule(value: "\(completedCount)", label: "Completed", tint: Theme.success)
            StatCapsule(value: "\(averageProgress)%", label: "Avg progress", tint: Theme.info)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Brand.primary)
            Text("No onboardings yet")
                .font(Theme.Font.section)
                .foregroundStyle(Theme.Ink.primary)
            Text(templates.isEmpty
                 ? "Create a template first, then start onboarding people from it."
                 : "Add a new hire to track their stages.")
                .font(Theme.Font.callout)
                .foregroundStyle(Theme.Ink.secondary)
                .multilineTextAlignment(.center)
            if !templates.isEmpty {
                Button {
                    isShowingNew = true
                } label: {
                    Label("New onboarding", systemImage: "plus")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, Theme.Spacing.m)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .threadCard()
    }

    private var activeCount: Int { onboardings.filter { !$0.isFullyComplete }.count }
    private var completedCount: Int { onboardings.filter(\.isFullyComplete).count }

    private var averageProgress: Int {
        guard !onboardings.isEmpty else { return 0 }
        let sum = onboardings.map(\.progress).reduce(0, +)
        return Int((sum / Double(onboardings.count)) * 100)
    }

    private func delete(_ onboarding: Onboarding) {
        context.delete(onboarding)
        try? context.save()
    }
}

private struct OnboardingRow: View {
    var onboarding: Onboarding

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: Theme.Spacing.m) {
                Avatar(name: onboarding.employee?.fullName ?? "?", diameter: 46)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(onboarding.employee?.fullName ?? "Unnamed employee")
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Ink.primary)
                    Text("\(onboarding.employee?.position ?? "—") · \(onboarding.employee?.location ?? "—")")
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Ink.secondary)
                    HStack(spacing: Theme.Spacing.s) {
                        Pill(onboarding.templateName, systemImage: "rectangle.connected.to.line.below",
                             tint: Theme.Brand.primary)
                        if let startCountdown = onboarding.employee?.startCountdown {
                            Pill(startCountdown, systemImage: "calendar")
                        }
                    }
                }

                Spacer(minLength: 0)
                ProgressRing(progress: onboarding.progress,
                             tint: onboarding.isFullyComplete ? Theme.success : Theme.Brand.primary,
                             diameter: 52,
                             lineWidth: 6)
            }
        }
    }
}

#Preview {
    OnboardingsListView()
        .modelContainer(ModelContainerFactory.makePreview())
}
