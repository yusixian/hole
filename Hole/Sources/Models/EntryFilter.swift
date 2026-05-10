import Foundation

struct EntryFilter: Equatable {
    var query: String = ""
    var moods: Set<Mood> = []
    var tagNames: Set<String> = []
    var includePrivate: Bool = false

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isEmpty: Bool {
        trimmedQuery.isEmpty && moods.isEmpty && tagNames.isEmpty && includePrivate == false
    }

    func matches(_ entry: Entry) -> Bool {
        if !includePrivate && entry.isPrivate {
            return false
        }
        if !moods.isEmpty {
            guard let m = entry.mood, moods.contains(m) else { return false }
        }
        if !tagNames.isEmpty {
            let entryTagNames = Set(entry.tags.map(\.name))
            if entryTagNames.isDisjoint(with: tagNames) {
                return false
            }
        }
        let q = trimmedQuery
        if !q.isEmpty {
            let lowerQ = q.lowercased()
            let bodyHit = entry.body.lowercased().contains(lowerQ)
            let tagHit = entry.tags.contains { $0.name.lowercased().contains(lowerQ) }
            let aiHit = (entry.aiSummary?.lowercased().contains(lowerQ) ?? false)
                || (entry.aiEcho?.lowercased().contains(lowerQ) ?? false)
            if !(bodyHit || tagHit || aiHit) { return false }
        }
        return true
    }
}
