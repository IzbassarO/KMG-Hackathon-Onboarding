import SwiftUI
import SwiftData

/// Two-step sheet: pick a template, then fill in the employee.
struct NewOnboardingSheet: View {
    var templates: [Template]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTemplate: Template?
    @State private var fullName: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: .now) ?? .now
    @State private var hasBirthDate: Bool = false
    @State private var contractType: String = "Direct"
    @State private var contractNumber: String = ""
    @State private var position: String = ""
    @State private var department: String = ""
    @State private var location: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now

    private let contractTypes = ["Direct", "Contractor", "Intern", "Rotational"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    Picker("Template", selection: $selectedTemplate) {
                        Text("Pick a template").tag(nil as Template?)
                        ForEach(templates) { template in
                            Text(template.name).tag(template as Template?)
                        }
                    }
                    if let summary = selectedTemplate?.summary, !summary.isEmpty {
                        Text(summary)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.Ink.secondary)
                    }
                }

                Section("Person") {
                    TextField("Full name", text: $fullName)
                        .textContentType(.name)
                    Toggle("Specify date of birth", isOn: $hasBirthDate)
                    if hasBirthDate {
                        DatePicker("Date of birth", selection: $birthDate,
                                   in: ...Date.now, displayedComponents: .date)
                    }
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("Contract") {
                    Picker("Type", selection: $contractType) {
                        ForEach(contractTypes, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Contract number", text: $contractNumber)
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                }

                Section("Role") {
                    TextField("Position (e.g. Driller)", text: $position)
                    TextField("Department (e.g. Upstream Operations)", text: $department)
                    TextField("Location (e.g. Kashagan)", text: $location)
                }
            }
            .navigationTitle("New onboarding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: create)
                        .disabled(!canCreate)
                }
            }
            .onAppear {
                if selectedTemplate == nil { selectedTemplate = templates.first }
            }
        }
    }

    private var canCreate: Bool {
        selectedTemplate != nil &&
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func create() {
        guard let template = selectedTemplate else { return }
        let employee = Employee(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: hasBirthDate ? birthDate : nil,
            contractType: contractType,
            contractNumber: contractNumber,
            position: position,
            department: department,
            location: location,
            startDate: startDate,
            email: email,
            phone: phone
        )
        _ = OnboardingFactory.make(from: template, employee: employee, context: context)
        dismiss()
    }
}
