import Foundation
import SwiftData

/// Personal & employment details captured by the New Onboarding form.
@Model
final class Employee {
    @Attribute(.unique) var id: UUID
    var fullName: String
    var birthDate: Date?
    var contractType: String
    var contractNumber: String
    var position: String
    var department: String
    var location: String
    var startDate: Date
    var email: String
    var phone: String

    init(
        id: UUID = UUID(),
        fullName: String,
        birthDate: Date? = nil,
        contractType: String = "Direct",
        contractNumber: String = "",
        position: String = "",
        department: String = "",
        location: String = "",
        startDate: Date = .now,
        email: String = "",
        phone: String = ""
    ) {
        self.id = id
        self.fullName = fullName
        self.birthDate = birthDate
        self.contractType = contractType
        self.contractNumber = contractNumber
        self.position = position
        self.department = department
        self.location = location
        self.startDate = startDate
        self.email = email
        self.phone = phone
    }

    var ageYears: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: .now).year
    }

    var startCountdown: String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: startDate).day ?? 0
        if days < 0 { return "Started \(-days) day(s) ago" }
        if days == 0 { return "Starts today" }
        if days == 1 { return "Starts tomorrow" }
        return "Starts in \(days) days"
    }
}
