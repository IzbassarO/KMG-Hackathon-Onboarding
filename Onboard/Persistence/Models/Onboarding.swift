import Foundation
import SwiftData

/// An employee being onboarded against a snapshot of a template's flowchart.
/// Stages and links are full copies so the source template can evolve
/// independently.
@Model
final class Onboarding {
    @Attribute(.unique) var id: UUID
    var templateName: String
    var templateCategory: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var employee: Employee?

    @Relationship(deleteRule: .cascade, inverse: \OnboardingStage.onboarding)
    var stages: [OnboardingStage] = []

    @Relationship(deleteRule: .cascade, inverse: \OnboardingLink.onboarding)
    var links: [OnboardingLink] = []

    init(
        id: UUID = UUID(),
        templateName: String,
        templateCategory: String = "",
        createdAt: Date = .now,
        employee: Employee? = nil
    ) {
        self.id = id
        self.templateName = templateName
        self.templateCategory = templateCategory
        self.createdAt = createdAt
        self.employee = employee
    }

    var totalStages: Int { stages.count }
    var completedStages: Int { stages.filter(\.isCompleted).count }

    var progress: Double {
        guard !stages.isEmpty else { return 0 }
        return Double(completedStages) / Double(stages.count)
    }

    var isFullyComplete: Bool { !stages.isEmpty && completedStages == stages.count }
}
