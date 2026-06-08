import Foundation
import SwiftData

/// A ticket inside an active onboarding. Mirrors a TemplateStage but adds a
/// user-driven status (Open → In progress → Done → Blocked). Nothing changes
/// status automatically — the user raises, edits, and advances tickets.
@Model
final class OnboardingStage {
    @Attribute(.unique) var id: UUID
    var title: String
    var owner: String
    var notes: String
    var estimatedDays: Int
    var priorityRaw: String
    var statusRaw: String
    var positionX: Double
    var positionY: Double
    var completedAt: Date?
    var onboarding: Onboarding?

    init(
        id: UUID = UUID(),
        title: String,
        owner: String = "",
        notes: String = "",
        estimatedDays: Int = 1,
        priority: TicketPriority = .medium,
        status: TicketStatus = .open,
        positionX: Double = 0,
        positionY: Double = 0,
        completedAt: Date? = nil,
        onboarding: Onboarding? = nil
    ) {
        self.id = id
        self.title = title
        self.owner = owner
        self.notes = notes
        self.estimatedDays = estimatedDays
        self.priorityRaw = priority.rawValue
        self.statusRaw = status.rawValue
        self.positionX = positionX
        self.positionY = positionY
        self.completedAt = completedAt
        self.onboarding = onboarding
    }

    var priority: TicketPriority {
        get { TicketPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var status: TicketStatus {
        get { TicketStatus(rawValue: statusRaw) ?? .open }
        set {
            statusRaw = newValue.rawValue
            completedAt = newValue == .done ? (completedAt ?? Date()) : nil
        }
    }

    var isCompleted: Bool { status == .done }

    /// Advances to the next status in the quick-cycle order.
    func advanceStatus() {
        status = status.next
    }
}
