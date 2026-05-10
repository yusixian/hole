import XCTest
import SwiftData
@testable import Hole

@MainActor
final class EntryFilterTests: XCTestCase {
    private var container: ModelContainer!
    private var store: EntryStore!

    override func setUpWithError() throws {
        container = ModelSchema.makeContainer(inMemory: true)
        store = EntryStore(context: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        store = nil
    }

    func testEmptyFilterMatchesPublicOnly() throws {
        let pub = try store.create(body: "public note")
        let priv = try store.create(body: "private note", isPrivate: true)
        var f = EntryFilter()
        XCTAssertTrue(f.matches(pub))
        XCTAssertFalse(f.matches(priv))
        f.includePrivate = true
        XCTAssertTrue(f.matches(priv))
    }

    func testQueryMatchesBodyCaseInsensitive() throws {
        let entry = try store.create(body: "Today felt Calm")
        var f = EntryFilter(); f.query = "calm"
        XCTAssertTrue(f.matches(entry))
        f.query = "stormy"
        XCTAssertFalse(f.matches(entry))
    }

    func testQueryMatchesTagName() throws {
        let entry = try store.create(body: "x", tagNames: ["focus"])
        var f = EntryFilter(); f.query = "FOC"
        XCTAssertTrue(f.matches(entry))
    }

    func testQueryMatchesAIFields() throws {
        let entry = try store.create(body: "x")
        entry.aiEcho = "You sound thoughtful tonight."
        var f = EntryFilter(); f.query = "thoughtful"
        XCTAssertTrue(f.matches(entry))
    }

    func testMoodFilter() throws {
        let happy = try store.create(body: "h", mood: .veryGood)
        let sad = try store.create(body: "s", mood: .veryLow)
        var f = EntryFilter(); f.moods = [.veryGood]
        XCTAssertTrue(f.matches(happy))
        XCTAssertFalse(f.matches(sad))
    }

    func testTagFilter() throws {
        let a = try store.create(body: "a", tagNames: ["work"])
        let b = try store.create(body: "b", tagNames: ["home"])
        var f = EntryFilter(); f.tagNames = ["work"]
        XCTAssertTrue(f.matches(a))
        XCTAssertFalse(f.matches(b))
    }

    func testCombinedFilters() throws {
        let match = try store.create(
            body: "morning walk in spring",
            mood: .good,
            tagNames: ["walk"]
        )
        let miss = try store.create(
            body: "morning walk in spring",
            mood: .veryLow,
            tagNames: ["walk"]
        )
        var f = EntryFilter()
        f.query = "spring"
        f.moods = [.good]
        f.tagNames = ["walk"]
        XCTAssertTrue(f.matches(match))
        XCTAssertFalse(f.matches(miss))
    }
}
