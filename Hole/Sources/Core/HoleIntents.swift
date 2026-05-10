import AppIntents
import Foundation
import SwiftData

struct WriteEntryIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.write.title"
    static let description = IntentDescription("intent.write.description")
    static let openAppWhenRun: Bool = false

    @Parameter(title: "intent.param.body", inputOptions: .init(multiline: true))
    var body: String

    @Parameter(title: "intent.param.mood", default: 0)
    var moodValue: Int

    @Parameter(title: "intent.param.tags", default: [])
    var tags: [String]

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try IntentSupport.sharedContainer()
        let store = EntryStore(context: container.mainContext)
        let mood = Mood(rawValue: moodValue)
        let entry = try store.create(body: body, mood: mood, tagNames: tags)
        let preview = body.prefix(40)
        let dialog: IntentDialog = "Saved entry: \(String(preview))"
        _ = entry
        return .result(dialog: dialog)
    }
}

struct ReadRecentEntriesIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.recent.title"
    static let description = IntentDescription("intent.recent.description")
    static let openAppWhenRun: Bool = false

    @Parameter(title: "intent.param.count", default: 5)
    var count: Int

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[String]> & ProvidesDialog {
        let container = try IntentSupport.sharedContainer()
        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { !$0.isPrivate },
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = max(1, min(count, 20))
        let entries = try container.mainContext.fetch(descriptor)
        let bodies = entries.map(\.body)
        let dialog: IntentDialog = "Found \(bodies.count) recent entries."
        return .result(value: bodies, dialog: dialog)
    }
}

struct SearchEntriesIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.search.title"
    static let description = IntentDescription("intent.search.description")
    static let openAppWhenRun: Bool = false

    @Parameter(title: "intent.param.query")
    var query: String

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
        let container = try IntentSupport.sharedContainer()
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        let all = try container.mainContext.fetch(descriptor)
        var filter = EntryFilter()
        filter.query = query
        let matched = all.filter { filter.matches($0) }.map(\.body)
        return .result(value: matched)
    }
}

struct QueryStreakIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.streak.title"
    static let description = IntentDescription("intent.streak.description")
    static let openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let container = try IntentSupport.sharedContainer()
        let stats = StatsService(context: container.mainContext)
        let streak = try stats.currentStreakDays()
        let dialog: IntentDialog = "Your current streak is \(streak) days."
        return .result(value: streak, dialog: dialog)
    }
}

struct HoleAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WriteEntryIntent(),
            phrases: [
                "Write in \(.applicationName)",
                "Add a \(.applicationName) entry"
            ],
            shortTitle: "Write in Hole",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: QueryStreakIntent(),
            phrases: [
                "What is my \(.applicationName) streak",
                "\(.applicationName) streak"
            ],
            shortTitle: "Hole streak",
            systemImageName: "flame"
        )
        AppShortcut(
            intent: ReadRecentEntriesIntent(),
            phrases: [
                "Read recent \(.applicationName) entries"
            ],
            shortTitle: "Recent entries",
            systemImageName: "list.bullet"
        )
    }
}
