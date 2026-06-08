import Foundation
import SwiftData

/// A single ticket rectangle in a template's flowchart. Stores its content
/// (title, owner, notes, priority, estimate) and its position on the canvas.
@Model
final class TemplateStage {
    @Attribute(.unique) var id: UUID
    var title: String
    var owner: String
    var notes: String
    var estimatedDays: Int
    var priorityRaw: String
    var positionX: Double
    var positionY: Double
    var template: Template?

    init(
        id: UUID = UUID(),
        title: String,
        owner: String = "",
        notes: String = "",
        estimatedDays: Int = 1,
        priority: TicketPriority = .medium,
        positionX: Double = 0,
        positionY: Double = 0,
        template: Template? = nil
    ) {
        self.id = id
        self.title = title
        self.owner = owner
        self.notes = notes
        self.estimatedDays = estimatedDays
        self.priorityRaw = priority.rawValue
        self.positionX = positionX
        self.positionY = positionY
        self.template = template
    }

    var priority: TicketPriority {
        get { TicketPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
}
