import SwiftUI
import SwiftData

@main
struct HoleApp: App {
    @State private var themeManager = ThemeManager()
    @State private var aiCoordinator = AICoordinator()
    @State private var appLock = AppLockManager()
    @State private var vault = VaultManager()
    @Environment(\.scenePhase) private var scenePhase
    private let modelContainer: ModelContainer

    init() {
        self.modelContainer = ModelSchema.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            ThemedRoot {
                AppLockGate {
                    RootTabView()
                }
            }
            .environment(themeManager)
            .environment(aiCoordinator)
            .environment(appLock)
            .environment(vault)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background, .inactive:
                appLock.didEnterBackground()
                vault.didEnterBackground()
            case .active:
                appLock.willEnterForeground()
            @unknown default:
                break
            }
        }
    }
}
