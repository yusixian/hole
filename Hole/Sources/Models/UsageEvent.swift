import Foundation
import SwiftData

@Model
final class UsageEvent {
    enum Kind: String, Codable, Sendable {
        case aiEcho
        case aiTag
        case aiSummary
        case aiChat
        case aiMood
    }

    enum Provider: String, Codable, Sendable {
        case local
        case openai
        case anthropic
        case gemini
    }

    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var providerRaw: String
    var promptTokens: Int
    var completionTokens: Int
    var at: Date

    init(
        id: UUID = UUID(),
        kind: Kind,
        provider: Provider,
        promptTokens: Int = 0,
        completionTokens: Int = 0,
        at: Date = .now
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.providerRaw = provider.rawValue
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.at = at
    }

    var kind: Kind {
        get { Kind(rawValue: kindRaw) ?? .aiEcho }
        set { kindRaw = newValue.rawValue }
    }

    var provider: Provider {
        get { Provider(rawValue: providerRaw) ?? .local }
        set { providerRaw = newValue.rawValue }
    }
}
