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
        context.delete(entry)
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
