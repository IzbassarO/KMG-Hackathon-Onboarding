import Foundation
import SwiftData

/// Seeds the database with starter templates on first launch so the user sees
/// a working flowchart immediately instead of an empty slate.
enum StarterTemplates {
    /// Inserts starter templates if the database has none. Pass `force: true`
    /// for preview containers to always seed.
    static func seedIfNeeded(in context: ModelContext, force: Bool = false) {
        if !force {
            let fetch = FetchDescriptor<Template>()
            if let count = try? context.fetchCount(fetch), count > 0 { return }
        }

        for template in defaults() {
            context.insert(template)
        }
        try? context.save()
    }

    // MARK: - Defaults

    static func defaults() -> [Template] {
        [directHire(), contractor(), fieldRotation()]
    }

    private static func directHire() -> Template {
        let template = Template(
            name: "Direct hire (full)",
            summary: "Standard onboarding for a direct employee at HQ.",
            category: "Direct hire"
        )
        let stages = [
            stage("HR contract signing", owner: "HR", row: 0, priority: .high),
            stage("ID card issuance", owner: "Badge Center", row: 1, priority: .high, days: 2),
            stage("Laptop provisioning", owner: "IT Service Desk", row: 2, days: 3),
            stage("M365 account", owner: "IT Service Desk", row: 3),
            stage("Mailbox & DLs", owner: "IT Service Desk", row: 4),
            stage("HSE induction", owner: "HSE", row: 5, priority: .high, days: 2),
            stage("Building pass", owner: "Physical Security", row: 6)
        ]
        return assemble(template: template, stages: stages)
    }

    private static func contractor() -> Template {
        let template = Template(
            name: "Contractor",
            summary: "Limited provisioning for a contractor with guest access.",
            category: "Contractor"
        )
        let stages = [
            stage("Contractor agreement", owner: "Legal", row: 0),
            stage("Loaner laptop", owner: "IT Service Desk", row: 1),
            stage("Guest M365 account", owner: "IT Service Desk", row: 2),
            stage("Visitor badge", owner: "Physical Security", row: 3)
        ]
        return assemble(template: template, stages: stages)
    }

    private static func fieldRotation() -> Template {
        let template = Template(
            name: "Field rotation",
            summary: "Rotational worker bound to a remote field site.",
            category: "Field rotation"
        )
        let stages = [
            stage("HR contract signing", owner: "HR", row: 0),
            stage("HSE field induction", owner: "HSE", row: 1),
            stage("Site access pass", owner: "Physical Security", row: 2),
            stage("Rugged laptop", owner: "IT Service Desk", row: 3),
            stage("Operations briefing", owner: "Upstream Operations", row: 4)
        ]
        return assemble(template: template, stages: stages)
    }

    // MARK: - Helpers

    private static let canvasOriginX: Double = 180
    private static let canvasRowSpacing: Double = 140

    private static func stage(
        _ title: String,
        owner: String,
        row: Int,
        priority: TicketPriority = .medium,
        days: Int = 1
    ) -> TemplateStage {
        TemplateStage(
            title: title,
            owner: owner,
            estimatedDays: days,
            priority: priority,
            positionX: canvasOriginX,
            positionY: 120 + Double(row) * canvasRowSpacing
        )
    }

    private static func assemble(template: Template, stages: [TemplateStage]) -> Template {
        for stage in stages {
            stage.template = template
            template.stages.append(stage)
        }
        for index in 0..<(stages.count - 1) {
            let link = TemplateLink(
                fromStageID: stages[index].id,
                toStageID: stages[index + 1].id,
                template: template
            )
            template.links.append(link)
        }
        return template
    }
}
