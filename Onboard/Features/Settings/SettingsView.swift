import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("threadline.userName") private var userName: String = ""
    @AppStorage("threadline.colorScheme") private var schemeRaw: String = ColorSchemePreference.system.rawValue
    @AppStorage("threadline.hasCompletedWelcome") private var hasCompletedWelcome = false

    @Query private var templates: [Template]
    @Query private var onboardings: [Onboarding]
    @Query private var employees: [Employee]

    @State private var isShowingResetConfirm = false
    @State private var isShowingReseedConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: Theme.Spacing.m) {
                        ThreadlineLogo(size: 48)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Threadline")
                                .font(Theme.Font.headline)
                            Text("Onboarding tracker for KMG hackathon")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Theme.Ink.secondary)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                }

                Section("You") {
                    TextField("Your name", text: $userName)
                        .textContentType(.name)
                }

                Section("Appearance") {
                    Picker("Theme", selection: $schemeRaw) {
                        ForEach(ColorSchemePreference.allCases) { pref in
                            Text(pref.displayName).tag(pref.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Library") {
                    LabeledRow(label: "Templates", value: "\(templates.count)")
                    LabeledRow(label: "Onboardings", value: "\(onboardings.count)")
                    LabeledRow(label: "Employees", value: "\(employees.count)")
                    Button {
                        isShowingReseedConfirm = true
                    } label: {
                        Label("Re-add starter templates", systemImage: "arrow.clockwise")
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        isShowingResetConfirm = true
                    } label: {
                        Label("Reset all data", systemImage: "trash")
                    }
                    Button {
                        hasCompletedWelcome = false
                    } label: {
                        Label("Show welcome on next launch", systemImage: "sparkles")
                    }
                }

                Section("About") {
                    LabeledRow(label: "Version", value: "1.0 (1)")
                    LabeledRow(label: "Built for", value: "KMG Digital Hackathon 2026")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "This deletes every template, onboarding, and employee.",
                isPresented: $isShowingResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete everything", role: .destructive, action: resetAll)
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog(
                "Re-add the three starter templates? Existing templates stay.",
                isPresented: $isShowingReseedConfirm,
                titleVisibility: .visible
            ) {
                Button("Add starter templates", action: reseed)
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func resetAll() {
        for onboarding in onboardings { context.delete(onboarding) }
        for template in templates { context.delete(template) }
        for employee in employees { context.delete(employee) }
        try? context.save()
    }

    private func reseed() {
        for template in StarterTemplates.defaults() {
            context.insert(template)
        }
        try? context.save()
    }
}

private struct LabeledRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.Ink.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(ModelContainerFactory.makePreview())
}
