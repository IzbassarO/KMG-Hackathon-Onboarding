import Foundation

/// Lifecycle of a ticket inside an active onboarding. The user moves a ticket
/// through these manually — nothing advances automatically.
enum TicketStatus: String, CaseIterable, Identifiable, Codable {
    case open
    case inProgress
    case done
    case blocked

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In progress"
        case .done: return "Done"
        case .blocked: return "Blocked"
        }
    }

    var systemImage: String {
        switch self {
        case .open: return "circle"
        case .inProgress: return "clock.fill"
        case .done: return "checkmark.circle.fill"
        case .blocked: return "exclamationmark.octagon.fill"
        }
    }

    /// Order used when cycling status via a quick tap.
    var next: TicketStatus {
        switch self {
        case .open: return .inProgress
        case .inProgress: return .done
        case .done: return .open
        case .blocked: return .open
        }
    }
}

enum TicketPriority: String, CaseIterable, Identifiable, Codable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var systemImage: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "arrow.up"
        }
    }
}
