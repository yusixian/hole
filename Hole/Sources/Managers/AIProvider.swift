import Foundation

struct AIInsight: Sendable, Equatable {
    var echo: String?
    var summary: String?
    var moodSuggested: Mood?
    var tagsSuggested: [String]
}

enum AIProviderKind: String, Codable, Sendable, CaseIterable {
    case localStub
    case appleFoundation
    case anthropic
    case openai
    case gemini
}

protocol AIProvider: Sendable {
    var kind: AIProviderKind { get }
    func reflect(on body: String, persona: PersonaSnapshot, language: AILanguage) async throws -> AIInsight
}

enum AILanguage: String, Sendable {
    case zh, en

    static func detect(from body: String) -> AILanguage {
        for scalar in body.unicodeScalars {
            if (0x4E00...0x9FFF).contains(scalar.value) { return .zh }
        }
        return .en
    }
}

struct PersonaSnapshot: Sendable {
    let id: String
    let name: String
    let systemPromptZh: String
    let systemPromptEn: String

    func systemPrompt(for language: AILanguage) -> String {
        switch language {
        case .zh: systemPromptZh
        case .en: systemPromptEn
        }
    }
}

extension Persona {
    func snapshot() -> PersonaSnapshot {
        PersonaSnapshot(
            id: id,
            name: name,
            systemPromptZh: systemPromptZh,
            systemPromptEn: systemPromptEn
        )
    }
}
