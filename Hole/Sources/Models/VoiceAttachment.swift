import Foundation
import SwiftData

@Model
final class VoiceAttachment {
    @Attribute(.unique) var id: UUID
    var fileURL: String
    var transcript: String
    var durationSec: Double
    var createdAt: Date
    var entry: Entry?

    init(
        id: UUID = UUID(),
        fileURL: String,
        transcript: String = "",
        durationSec: Double = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.fileURL = fileURL
        self.transcript = transcript
        self.durationSec = durationSec
        self.createdAt = createdAt
    }
}
