import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            TemplatesListView()
                .tabItem { Label("Templates", systemImage: "rectangle.connected.to.line.below") }

            OnboardingsListView()
                .tabItem { Label("Onboardings", systemImage: "person.2.badge.gearshape") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(ModelContainerFactory.makePreview())
}
