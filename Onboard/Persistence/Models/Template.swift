import Foundation
import SwiftData

/// A reusable onboarding flowchart authored by the user. Owns its own stages
/// and stage-to-stage links. Instantiating an onboarding clones these into the
/// onboarding's own copy so later edits to the template never mutate active
/// onboardings.
@Model
final class Template {
    @Attribute(.unique) var id: UUID
    var name: String
    var summary: String
    var category: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TemplateStage.template)
    var stages: [TemplateStage] = []

    @Relationship(deleteRule: .cascade, inverse: \TemplateLink.template)
    var links: [TemplateLink] = []

    init(
        id: UUID = UUID(),
        name: String,
        summary: String = "",
        category: String = "Direct hire",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.category = category
        self.createdAt = createdAt
    }

    var stageCount: Int { stages.count }

    /// Stable display order for the canvas — by node Y then X so visual
    /// layout stays predictable when rendered.
    var orderedStages: [TemplateStage] {
        stages.sorted { lhs, rhs in
            if lhs.positionY != rhs.positionY { return lhs.positionY < rhs.positionY }
            return lhs.positionX < rhs.positionX
        }
    }
}
