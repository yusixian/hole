import Foundation
import SwiftData

@MainActor
struct StatsService {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func currentStreakDays(asOf reference: Date = .now) throws -> Int {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        let all = try context.fetch(descriptor)
        guard !all.isEmpty else { return 0 }

        var entryDays = Set<DateComponents>()
        for entry in all {
            let dc = calendar.dateComponents([.year, .month, .day], from: entry.createdAt)
            entryDays.insert(dc)
        }

        var streak = 0
        var cursor = calendar.startOfDay(for: reference)
        while true {
            let dc = calendar.dateComponents([.year, .month, .day], from: cursor)
            if entryDays.contains(dc) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                cursor = prev
            } else {
                if streak == 0 && calendar.isDate(cursor, inSameDayAs: calendar.startOfDay(for: reference)) {
                    guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
                    cursor = prev
                    continue
                }
                break
            }
        }
        return streak
    }

    func monthMoodCounts(for anchor: Date = .now) throws -> [Int] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: anchor) else { return Array(repeating: 0, count: 5) }
        let lower = interval.start
        let upper = interval.end
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate {
                $0.createdAt >= lower && $0.createdAt < upper
            }
        )
        let entries = try context.fetch(descriptor)
        var counts = Array(repeating: 0, count: 5)
        for entry in entries {
            if let mood = entry.mood {
                counts[mood.rawValue - 1] += 1
            }
        }
        return counts
    }

    func entryCountThisMonth(asOf anchor: Date = .now) throws -> Int {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: anchor) else { return 0 }
        let lower = interval.start
        let upper = interval.end
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate {
                $0.createdAt >= lower && $0.createdAt < upper
            }
        )
        return try context.fetchCount(descriptor)
    }

    func entriesOnThisDay(asOf reference: Date = .now) throws -> [Entry] {
        let calendar = Calendar.current
        let referenceComponents = calendar.dateComponents([.month, .day], from: reference)
        let referenceMonth = referenceComponents.month ?? 0
        let referenceDay = referenceComponents.day ?? 0
        let referenceYear = calendar.component(.year, from: reference)

        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { !$0.isPrivate },
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        let all = try context.fetch(descriptor)
        return all.filter { entry in
            let comps = calendar.dateComponents([.year, .month, .day], from: entry.createdAt)
            guard
                let entryYear = comps.year,
                let entryMonth = comps.month,
                let entryDay = comps.day
            else { return false }
            return entryMonth == referenceMonth
                && entryDay == referenceDay
                && entryYear < referenceYear
        }
    }

    func aiUsageCounts() throws -> [String: Int] {
        let descriptor = FetchDescriptor<UsageEvent>()
        let events = try context.fetch(descriptor)
        var counts: [String: Int] = [:]
        for event in events {
            counts[event.kindRaw, default: 0] += 1
        }
        return counts
    }
}
