import XCTest
import SwiftData
@testable import Hole

@MainActor
final class StatsServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var store: EntryStore!
    private var stats: StatsService!

    override func setUpWithError() throws {
        container = ModelSchema.makeContainer(inMemory: true)
        store = EntryStore(context: container.mainContext)
        stats = StatsService(context: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        store = nil
        stats = nil
    }

    func testStreakWithNoEntries() throws {
        XCTAssertEqual(try stats.currentStreakDays(), 0)
    }

    func testStreakSingleDayToday() throws {
        _ = try store.create(body: "today")
        XCTAssertEqual(try stats.currentStreakDays(), 1)
    }

    func testStreakConsecutiveDays() throws {
        let cal = Calendar.current
        let now = Date()
        for offset in 0..<3 {
            let day = cal.date(byAdding: .day, value: -offset, to: now)!
            _ = try store.create(body: "d\(offset)", createdAt: day)
        }
        XCTAssertEqual(try stats.currentStreakDays(), 3)
    }

    func testStreakResetsOnGap() throws {
        let cal = Calendar.current
        let now = Date()
        for offset in [0, 2, 3] {
            let day = cal.date(byAdding: .day, value: -offset, to: now)!
            _ = try store.create(body: "d\(offset)", createdAt: day)
        }
        XCTAssertEqual(try stats.currentStreakDays(), 1)
    }

    func testStreakAllowsMissingTodayKeepsYesterdayStreak() throws {
        let cal = Calendar.current
        let now = Date()
        for offset in 1..<4 {
            let day = cal.date(byAdding: .day, value: -offset, to: now)!
            _ = try store.create(body: "d\(offset)", createdAt: day)
        }
        XCTAssertEqual(try stats.currentStreakDays(), 3)
    }

    func testMonthMoodCounts() throws {
        _ = try store.create(body: "a", mood: .good)
        _ = try store.create(body: "b", mood: .good)
        _ = try store.create(body: "c", mood: .veryLow)
        let counts = try stats.monthMoodCounts()
        XCTAssertEqual(counts.count, 5)
        XCTAssertEqual(counts[Mood.good.rawValue - 1], 2)
        XCTAssertEqual(counts[Mood.veryLow.rawValue - 1], 1)
    }

    func testEntryCountThisMonth() throws {
        _ = try store.create(body: "x")
        _ = try store.create(body: "y")
        XCTAssertEqual(try stats.entryCountThisMonth(), 2)
    }

    func testAiUsageEmpty() throws {
        XCTAssertTrue(try stats.aiUsageCounts().isEmpty)
    }

    func testOnThisDayMatchesPreviousYears() throws {
        let cal = Calendar.current
        let now = Date()
        let lastYearSameDay = cal.date(byAdding: .year, value: -1, to: now)!
        let twoYearsAgoSameDay = cal.date(byAdding: .year, value: -2, to: now)!
        let unrelatedDay = cal.date(byAdding: .day, value: -3, to: now)!

        _ = try store.create(body: "last year", createdAt: lastYearSameDay)
        _ = try store.create(body: "two years ago", createdAt: twoYearsAgoSameDay)
        _ = try store.create(body: "unrelated", createdAt: unrelatedDay)
        _ = try store.create(body: "today")

        let entries = try stats.entriesOnThisDay(asOf: now)
        let bodies = entries.map(\.body).sorted()
        XCTAssertEqual(bodies, ["last year", "two years ago"])
    }

    func testOnThisDayExcludesPrivate() throws {
        let cal = Calendar.current
        let lastYear = cal.date(byAdding: .year, value: -1, to: Date())!
        _ = try store.create(body: "secret last year", isPrivate: true, createdAt: lastYear)
        _ = try store.create(body: "public last year", createdAt: lastYear)
        let entries = try stats.entriesOnThisDay()
        XCTAssertEqual(entries.map(\.body), ["public last year"])
    }
}
