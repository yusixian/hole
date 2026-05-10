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
            .onOpenURL { url in
                handleIncomingURL(url)
            }
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

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "hole" else { return }
        guard url.host == "create" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let body = components?.queryItems?.first(where: { $0.name == "body" })?.value ?? ""
        let moodValue = Int(components?.queryItems?.first(where: { $0.name == "mood" })?.value ?? "")
        let tagsRaw = components?.queryItems?.first(where: { $0.name == "tags" })?.value ?? ""
        let tags = tagsRaw.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard !body.isEmpty else { return }
        let store = EntryStore(context: modelContainer.mainContext, vault: vault)
        do {
            let entry = try store.create(
                body: body,
                mood: moodValue.flatMap(Mood.init(rawValue:)),
                tagNames: tags
            )
            aiCoordinator.reflectAfterSave(entry, in: modelContainer.mainContext)
        } catch {
            // swallow — URL flow is fire-and-forget
        }
    }
}
