import Foundation
import SwiftData

/// Creates a new `Onboarding` by deep-cloning a `Template`'s stages and links.
/// Cloning means the user can keep editing the source template without
/// retroactively changing onboardings already in flight.
enum OnboardingFactory {
    @MainActor
    static func make(
        from template: Template,
        employee: Employee,
        context: ModelContext
    ) -> Onboarding {
        let onboarding = Onboarding(
            templateName: template.name,
            templateCategory: template.category,
            employee: employee
        )

        var idRemap: [UUID: UUID] = [:]
        for source in template.orderedStages {
            let copy = OnboardingStage(
                title: source.title,
                owner: source.owner,
                notes: source.notes,
                estimatedDays: source.estimatedDays,
                priority: source.priority,
                status: .open,
                positionX: source.positionX,
                positionY: source.positionY,
                onboarding: onboarding
            )
            idRemap[source.id] = copy.id
            onboarding.stages.append(copy)
        }
        for source in template.links {
            guard
                let mappedFrom = idRemap[source.fromStageID],
                let mappedTo = idRemap[source.toStageID]
            else { continue }
            let link = OnboardingLink(
                fromStageID: mappedFrom,
                toStageID: mappedTo,
                onboarding: onboarding
            )
            onboarding.links.append(link)
        }

        context.insert(employee)
        context.insert(onboarding)
        try? context.save()
        return onboarding
    }
}
