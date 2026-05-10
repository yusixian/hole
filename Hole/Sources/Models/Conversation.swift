import Foundation
import SwiftData

@Model
final class Conversation {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var personaID: String

    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []

    init(
        id: UUID = UUID(),
        title: String = "",
        personaID: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.personaID = personaID
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}
