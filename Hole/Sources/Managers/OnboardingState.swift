import Foundation
import Observation

@MainActor
@Observable
final class OnboardingState {
    private static let completedKey = "onboarding.completed"

    var hasCompleted: Bool {
        didSet { UserDefaults.standard.set(hasCompleted, forKey: Self.completedKey) }
    }

    init() {
        self.hasCompleted = UserDefaults.standard.bool(forKey: Self.completedKey)
    }

    func markCompleted() {
        hasCompleted = true
    }

    func reset() {
        hasCompleted = false
    }
}
