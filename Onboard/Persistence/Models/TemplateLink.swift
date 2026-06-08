import Foundation
import SwiftData

/// A directed edge between two TemplateStages on the same template canvas.
/// IDs are stored rather than direct references so cloning into onboardings is
/// a simple ID remap.
@Model
final class TemplateLink {
    @Attribute(.unique) var id: UUID
    var fromStageID: UUID
    var toStageID: UUID
    var template: Template?

    init(
        id: UUID = UUID(),
        fromStageID: UUID,
        toStageID: UUID,
        template: Template? = nil
    ) {
        self.id = id
        self.fromStageID = fromStageID
        self.toStageID = toStageID
        self.template = template
    }
}
