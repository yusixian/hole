import Foundation
import SwiftData

@Model
final class Entry {
    @Attribute(.unique) var id: UUID
    var body: String
    var createdAt: Date
    var updatedAt: Date

    var moodRaw: Int?
    var isPrivate: Bool
    var encryptedBlob: Data?

    var aiEcho: String?
    var aiSummary: String?
    var aiMoodSuggestedRaw: Int?
    var aiTagsSuggested: [String]

    @Relationship var tags: [Tag] = []
    @Relationship(deleteRule: .cascade) var voiceAttachments: [VoiceAttachment] = []
    @Relationship(deleteRule: .cascade) var imageAttachments: [ImageAttachment] = []

    init(
        id: UUID = UUID(),
        body: String = "",
        createdAt: Date = .now,
        mood: Mood? = nil,
        isPrivate: Bool = false
    ) {
        self.id = id
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.moodRaw = mood?.rawValue
        self.isPrivate = isPrivate
        self.aiTagsSuggested = []
    }

    var mood: Mood? {
        get { moodRaw.flatMap(Mood.init(rawValue:)) }
        set { moodRaw = newValue?.rawValue }
    }

    var aiMoodSuggested: Mood? {
        get { aiMoodSuggestedRaw.flatMap(Mood.init(rawValue:)) }
        set { aiMoodSuggestedRaw = newValue?.rawValue }
    }
}
