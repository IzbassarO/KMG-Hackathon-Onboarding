import SwiftUI

struct EmployeeEditorSheet: View {
    @Bindable var employee: Employee
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var hasBirthDate: Bool

    private let contractTypes = ["Direct", "Contractor", "Intern", "Rotational"]

    init(employee: Employee, onSave: @escaping () -> Void) {
        self._employee = Bindable(wrappedValue: employee)
        self.onSave = onSave
        _hasBirthDate = State(initialValue: employee.birthDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Full name", text: $employee.fullName)
                    Toggle("Specify date of birth", isOn: $hasBirthDate)
                        .onChange(of: hasBirthDate) { _, newValue in
                            if !newValue { employee.birthDate = nil }
                            else if employee.birthDate == nil {
                                employee.birthDate = Calendar.current.date(byAdding: .year, value: -30, to: .now)
                            }
                        }
                    if hasBirthDate {
                        DatePicker("Date of birth",
                                   selection: Binding(
                                       get: { employee.birthDate ?? .now },
                                       set: { employee.birthDate = $0 }
                                   ),
                                   in: ...Date.now,
                                   displayedComponents: .date)
                    }
                    TextField("Email", text: $employee.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $employee.phone)
                        .keyboardType(.phonePad)
                }

                Section("Contract") {
                    Picker("Type", selection: $employee.contractType) {
                        ForEach(contractTypes, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Contract number", text: $employee.contractNumber)
                    DatePicker("Start date", selection: $employee.startDate, displayedComponents: .date)
                }

                Section("Role") {
                    TextField("Position", text: $employee.position)
                    TextField("Department", text: $employee.department)
                    TextField("Location", text: $employee.location)
                }
            }
            .navigationTitle("Edit employee")
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
}
