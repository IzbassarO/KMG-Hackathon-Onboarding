import SwiftUI

/// Raise / edit a ticket on a live onboarding. This is the main ticket surface:
/// status, priority, owner, estimate, notes — plus delete.
struct OnboardingStageEditorSheet: View {
    @Bindable var stage: OnboardingStage
    var onSave: () -> Void
    var onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    private let ownerSuggestions = [
        "HR", "IT Service Desk", "Badge Center", "Physical Security",
        "HSE", "Legal", "Finance", "Upstream Operations"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Status") {
                    Picker("Status", selection: statusBinding) {
                        ForEach(TicketStatus.allCases) { s in
                            Text(s.displayName).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    if let completedAt = stage.completedAt {
                        Label("Done \(completedAt.formatted(date: .abbreviated, time: .shortened))",
                              systemImage: "checkmark.seal")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.success)
                    }
                }

                Section("Ticket") {
                    TextField("Title", text: $stage.title)
                    TextField("Responsible team", text: $stage.owner)
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
                        .frame(minHeight: 90)
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

                Section {
                    Button(role: .destructive) {
                        // Parent dismisses (sets item to nil) then deletes after
                        // the sheet closes, so we never read a deleted model.
                        onDelete()
                    } label: {
                        Label("Delete ticket", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Ticket")
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

    private var statusBinding: Binding<TicketStatus> {
        Binding(get: { stage.status }, set: { stage.status = $0 })
    }

    private var priorityBinding: Binding<TicketPriority> {
        Binding(get: { stage.priority }, set: { stage.priority = $0 })
    }
}
