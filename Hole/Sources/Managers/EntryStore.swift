import Foundation
import SwiftData

@MainActor
struct EntryStore {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func create(
        body: String,
        mood: Mood? = nil,
        tagNames: [String] = [],
        isPrivate: Bool = false,
        createdAt: Date = .now
    ) throws -> Entry {
        let entry = Entry(body: body, createdAt: createdAt, mood: mood, isPrivate: isPrivate)
        context.insert(entry)
        for name in normalize(tagNames) {
            entry.tags.append(try upsertTag(named: name))
        }
        try context.save()
        return entry
    }

    func update(
        _ entry: Entry,
        body: String? = nil,
        mood: Mood?? = nil,
        tagNames: [String]? = nil,
        isPrivate: Bool? = nil
    ) throws {
        if let body { entry.body = body }
        if case let .some(value) = mood { entry.mood = value }
        if let isPrivate { entry.isPrivate = isPrivate }
        if let tagNames {
            let names = normalize(tagNames)
            var tags: [Tag] = []
            for name in names {
                tags.append(try upsertTag(named: name))
            }
            entry.tags = tags
        }
        entry.updatedAt = .now
        try context.save()
    }

    func delete(_ entry: Entry) throws {
        let entryID = entry.id
        context.delete(entry)
        try context.save()
        if let dir = try? AttachmentStorage.directory(forEntryID: entryID) {
            try? FileManager.default.removeItem(at: dir)
        }
    }

    @discardableResult
    func attachVoice(
        to entry: Entry,
        from sourceURL: URL,
        transcript: String = "",
        duration: TimeInterval = 0
    ) throws -> VoiceAttachment {
        let dir = try AttachmentStorage.directory(forEntryID: entry.id)
        let dest = dir.appendingPathComponent("voice-\(UUID().uuidString).m4a")
        try AttachmentStorage.moveTemp(sourceURL, to: dest)
        let relative = AttachmentStorage.relativePath(for: dest)
        let attachment = VoiceAttachment(
            fileURL: relative,
            transcript: transcript,
            durationSec: duration
        )
        attachment.entry = entry
        entry.voiceAttachments.append(attachment)
        try context.save()
        return attachment
    }

    @discardableResult
    func attachImage(to entry: Entry, data: Data, fileExtension: String = "jpg") throws -> ImageAttachment {
        let dir = try AttachmentStorage.directory(forEntryID: entry.id)
        let dest = dir.appendingPathComponent("img-\(UUID().uuidString).\(fileExtension)")
        try AttachmentStorage.write(data, to: dest)
        let relative = AttachmentStorage.relativePath(for: dest)
        let attachment = ImageAttachment(fileURL: relative)
        attachment.entry = entry
        entry.imageAttachments.append(attachment)
        try context.save()
        return attachment
    }

    func removeVoice(_ attachment: VoiceAttachment) throws {
        if let abs = AttachmentStorage.absoluteURL(forRelative: attachment.fileURL) {
            try? FileManager.default.removeItem(at: abs)
        }
        context.delete(attachment)
        try context.save()
    }

    func removeImage(_ attachment: ImageAttachment) throws {
        if let abs = AttachmentStorage.absoluteURL(forRelative: attachment.fileURL) {
            try? FileManager.default.removeItem(at: abs)
        }
        context.delete(attachment)
        try context.save()
    }

    func upsertTag(named raw: String, isAI: Bool = false) throws -> Tag {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw EntryStoreError.emptyTagName }
        var fetch = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == name })
        fetch.fetchLimit = 1
        if let existing = try context.fetch(fetch).first {
            return existing
        }
        let tag = Tag(name: name, isAI: isAI)
        context.insert(tag)
        return tag
    }

    private func normalize(_ raw: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for item in raw {
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, !seen.contains(trimmed) else { continue }
            seen.insert(trimmed)
            result.append(trimmed)
        }
        return result
    }
}

enum EntryStoreError: Error {
    case emptyTagName
}
