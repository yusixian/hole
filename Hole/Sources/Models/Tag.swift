import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var name: String
    var createdAt: Date
    var isAI: Bool
    @Relationship(inverse: \Entry.tags) var entries: [Entry] = []

    init(name: String, isAI: Bool = false, createdAt: Date = .now) {
        self.name = name
        self.isAI = isAI
        self.createdAt = createdAt
    }
}
