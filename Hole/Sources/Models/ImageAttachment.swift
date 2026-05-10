import Foundation
import SwiftData

@Model
final class ImageAttachment {
    @Attribute(.unique) var id: UUID
    var fileURL: String
    var caption: String
    var createdAt: Date
    var entry: Entry?

    init(
        id: UUID = UUID(),
        fileURL: String,
        caption: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.fileURL = fileURL
        self.caption = caption
        self.createdAt = createdAt
    }
}
