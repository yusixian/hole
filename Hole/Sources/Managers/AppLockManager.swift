import Foundation
import LocalAuthentication
import Observation

@MainActor
@Observable
final class AppLockManager {
    private static let enabledKey = "applock.enabled"
    private static let backgroundGraceSeconds: TimeInterval = 5

    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey) }
    }

    private(set) var isLocked: Bool = false
    private(set) var lastError: String?

    private var lastBackgroundedAt: Date?

    init() {
        let defaults = UserDefaults.standard
        self.isEnabled = defaults.bool(forKey: Self.enabledKey)
        self.isLocked = self.isEnabled
    }

    var biometryAvailable: Bool {
        let ctx = LAContext()
        var error: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    var biometryReason: String {
        String(localized: "applock.reason")
    }

    func unlock() async {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            lastError = error?.localizedDescription ?? "no_biometry"
            return
        }
        do {
            let success = try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: biometryReason)
            isLocked = !success
            if success { lastError = nil }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func didEnterBackground() {
        guard isEnabled else { return }
        lastBackgroundedAt = .now
    }

    func willEnterForeground() {
        guard isEnabled else { return }
        if let last = lastBackgroundedAt {
            let elapsed = Date().timeIntervalSince(last)
            if elapsed >= Self.backgroundGraceSeconds {
                isLocked = true
            }
        } else {
            isLocked = true
        }
        lastBackgroundedAt = nil
    }

    func enable() async {
        isEnabled = true
        await unlock()
        if isLocked {
            isEnabled = false
        }
    }

    func disable() {
        isEnabled = false
        isLocked = false
    }
}
