import SwiftUI
import SwiftData

@main
struct HoleApp: App {
    @State private var themeManager = ThemeManager()
    @State private var aiCoordinator = AICoordinator()
    private let modelContainer: ModelContainer

    init() {
        self.modelContainer = ModelSchema.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            ThemedRoot {
                RootTabView()
            }
            .environment(themeManager)
            .environment(aiCoordinator)
        }
        .modelContainer(modelContainer)
    }
}
