import Foundation
import SwiftData

/// Directed edge inside an active onboarding's flowchart.
@Model
final class OnboardingLink {
    @Attribute(.unique) var id: UUID
    var fromStageID: UUID
    var toStageID: UUID
    var onboarding: Onboarding?

    init(
        id: UUID = UUID(),
        fromStageID: UUID,
        toStageID: UUID,
        onboarding: Onboarding? = nil
    ) {
        self.id = id
        self.fromStageID = fromStageID
        self.toStageID = toStageID
        self.onboarding = onboarding
    }
}
