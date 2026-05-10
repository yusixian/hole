import Foundation
import SwiftData

@MainActor
@Observable
final class AICoordinator {
    private static let echoEnabledKey = "ai.echo.enabled"
    private static let activePersonaKey = "ai.persona.active"

    var echoEnabled: Bool {
        didSet { UserDefaults.standard.set(echoEnabled, forKey: Self.echoEnabledKey) }
    }

    var activePersonaID: String {
        didSet { UserDefaults.standard.set(activePersonaID, forKey: Self.activePersonaKey) }
    }

    private(set) var inFlightEntries: Set<UUID> = []
    var lastError: String?

    private let provider: AIProvider

    init(provider: AIProvider = LocalAIProvider()) {
        self.provider = provider
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.echoEnabledKey) == nil {
            self.echoEnabled = true
        } else {
            self.echoEnabled = defaults.bool(forKey: Self.echoEnabledKey)
        }
        self.activePersonaID = defaults.string(forKey: Self.activePersonaKey) ?? "listener"
    }

    func reflectAfterSave(_ entry: Entry, in context: ModelContext) {
        guard echoEnabled, !entry.isPrivate else { return }
        let entryID = entry.id
        guard !inFlightEntries.contains(entryID) else { return }
        inFlightEntries.insert(entryID)

        let snapshot = resolvePersonaSnapshot(in: context)
        let body = entry.body
        let language = AILanguage.detect(from: body)

        Task { [provider] in
            do {
                let insight = try await provider.reflect(on: body, persona: snapshot, language: language)
                await MainActor.run {
                    apply(insight: insight, to: entry)
                    try? context.save()
                    self.inFlightEntries.remove(entryID)
                }
            } catch {
                await MainActor.run {
                    self.lastError = "\(error)"
                    self.inFlightEntries.remove(entryID)
                }
            }
        }
    }

    func clearInsights(on entry: Entry) {
        entry.aiEcho = nil
        entry.aiSummary = nil
        entry.aiMoodSuggested = nil
        entry.aiTagsSuggested = []
    }

    private func apply(insight: AIInsight, to entry: Entry) {
        entry.aiEcho = insight.echo ?? entry.aiEcho
        entry.aiSummary = insight.summary ?? entry.aiSummary
        if entry.aiMoodSuggested == nil {
            entry.aiMoodSuggested = insight.moodSuggested
        }
        if entry.aiTagsSuggested.isEmpty {
            entry.aiTagsSuggested = insight.tagsSuggested
        }
    }

    private func resolvePersonaSnapshot(in context: ModelContext) -> PersonaSnapshot {
        let target = activePersonaID
        var fetch = FetchDescriptor<Persona>(predicate: #Predicate { $0.id == target })
        fetch.fetchLimit = 1
        if let persona = try? context.fetch(fetch).first {
            return persona.snapshot()
        }
        return PersonaSnapshot(
            id: "listener",
            name: "Listener",
            systemPromptZh: "你是一位中立的倾听者。",
            systemPromptEn: "You are a neutral listener."
        )
    }
}
