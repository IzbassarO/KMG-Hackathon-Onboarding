import Foundation
import SwiftData

/// Builds the SwiftData container shared by the entire app. Models listed
/// explicitly so migrations remain predictable.
enum ModelContainerFactory {
    static let schemaModels: [any PersistentModel.Type] = [
        Template.self,
        TemplateStage.self,
        TemplateLink.self,
        Employee.self,
        Onboarding.self,
        OnboardingStage.self,
        OnboardingLink.self
    ]

    /// Production container persisted to disk.
    static func makeShared() -> ModelContainer {
        do {
            let schema = Schema(schemaModels)
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// In-memory container used by SwiftUI previews and tests.
    static func makePreview() -> ModelContainer {
        do {
            let schema = Schema(schemaModels)
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [config])
            StarterTemplates.seedIfNeeded(in: container.mainContext, force: true)
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }
}
