import SwiftUI
import SwiftData

@main
struct OnboardApp: App {
    @AppStorage("threadline.colorScheme") private var schemePreference: String = ColorSchemePreference.system.rawValue

    private let modelContainer: ModelContainer

    init() {
        let container = ModelContainerFactory.makeShared()
        StarterTemplates.seedIfNeeded(in: container.mainContext)
        self.modelContainer = container
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .tint(Theme.Brand.primary)
                .preferredColorScheme(
                    (ColorSchemePreference(rawValue: schemePreference) ?? .system).colorScheme
                )
                .environment(\.locale, Locale(identifier: "en"))
        }
        .modelContainer(modelContainer)
    }
}

/// Top-level switch between the first-run welcome flow and the main app.
struct AppRouter: View {
    @AppStorage("threadline.hasCompletedWelcome") private var hasCompletedWelcome = false

    var body: some View {
        Group {
            if hasCompletedWelcome {
                RootTabView()
            } else {
                WelcomeView(onFinish: { hasCompletedWelcome = true })
            }
        }
    }
}

enum ColorSchemePreference: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
