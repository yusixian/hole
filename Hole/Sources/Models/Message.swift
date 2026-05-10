import Foundation
import SwiftData

@Model
final class Message {
    enum Role: String, Codable, Sendable {
        case user
        case assistant
        case system
    }

    @Attribute(.unique) var id: UUID
    var roleRaw: String
    var content: String
    var createdAt: Date
    var conversation: Conversation?

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.roleRaw = role.rawValue
        self.content = content
        self.createdAt = createdAt
    }

    var role: Role {
        get { Role(rawValue: roleRaw) ?? .user }
        set { roleRaw = newValue.rawValue }
    }
}
