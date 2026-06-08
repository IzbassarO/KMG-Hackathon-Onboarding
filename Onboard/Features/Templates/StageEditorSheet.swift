import SwiftUI

/// Edit sheet for a template ticket (the blueprint). No status here — status
/// only exists on live onboarding tickets.
struct StageEditorSheet: View {
    @Bindable var stage: TemplateStage
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    private let ownerSuggestions = [
        "HR", "IT Service Desk", "Badge Center", "Physical Security",
        "HSE", "Legal", "Finance", "Upstream Operations"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Ticket") {
                    TextField("Title (e.g. ID card issuance)", text: $stage.title)
                    TextField("Responsible team (e.g. Badge Center)", text: $stage.owner)
                }

                Section("Details") {
                    Picker("Priority", selection: priorityBinding) {
                        ForEach(TicketPriority.allCases) { p in
                            Label(p.displayName, systemImage: p.systemImage).tag(p)
                        }
                    }
                    Stepper("Estimate: \(stage.estimatedDays) day(s)",
                            value: $stage.estimatedDays, in: 0...60)
                }

                Section("Notes") {
                    TextEditor(text: $stage.notes)
                        .frame(minHeight: 100)
                }

                Section("Suggested owners") {
                    ForEach(ownerSuggestions, id: \.self) { owner in
                        Button {
                            stage.owner = owner
                        } label: {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(owner)
                                Spacer()
                                if stage.owner == owner {
                                    Image(systemName: "checkmark").foregroundStyle(Theme.Brand.primary)
                                }
                            }
                        }
                        .tint(Theme.Ink.primary)
                    }
                }
            }
            .navigationTitle("Edit ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }

    private var priorityBinding: Binding<TicketPriority> {
        Binding(get: { stage.priority }, set: { stage.priority = $0 })
    }
}
