import XCTest
import SwiftData
@testable import Hole

@MainActor
final class EntryStoreTests: XCTestCase {
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

    func testCreateMinimalEntry() throws {
        let entry = try store.create(body: "first whisper")
        XCTAssertFalse(entry.id.uuidString.isEmpty)
        XCTAssertEqual(entry.body, "first whisper")
        XCTAssertNil(entry.mood)
        XCTAssertTrue(entry.tags.isEmpty)
        XCTAssertFalse(entry.isPrivate)
    }

    func testCreateWithMoodAndTags() throws {
        let entry = try store.create(
            body: "happy day",
            mood: .veryGood,
            tagNames: ["spring", "walk", "  "]
        )
        XCTAssertEqual(entry.mood, .veryGood)
        XCTAssertEqual(entry.tags.map(\.name).sorted(), ["spring", "walk"])
    }

    func testTagDedupAcrossEntries() throws {
        _ = try store.create(body: "a", tagNames: ["focus"])
        _ = try store.create(body: "b", tagNames: ["focus"])
        let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == "focus" })
        let tags = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tags.first?.entries.count, 2)
    }

    func testUpdateBodyAndMood() async throws {
        let entry = try store.create(body: "draft", mood: .neutral)
        let originalUpdatedAt = entry.updatedAt
        try await Task.sleep(nanoseconds: 10_000_000)
        try store.update(entry, body: "revised", mood: .some(.good))
        XCTAssertEqual(entry.body, "revised")
        XCTAssertEqual(entry.mood, .good)
        XCTAssertGreaterThan(entry.updatedAt, originalUpdatedAt)
    }

    func testUpdateClearMood() throws {
        let entry = try store.create(body: "x", mood: .low)
        try store.update(entry, mood: .some(nil))
        XCTAssertNil(entry.mood)
    }

    func testUpdateReplacesTags() throws {
        let entry = try store.create(body: "x", tagNames: ["a", "b"])
        try store.update(entry, tagNames: ["b", "c"])
        XCTAssertEqual(entry.tags.map(\.name).sorted(), ["b", "c"])
    }

    func testDeleteRemovesEntry() throws {
        let entry = try store.create(body: "ephemeral")
        try store.delete(entry)
        let all = try container.mainContext.fetch(FetchDescriptor<Entry>())
        XCTAssertTrue(all.isEmpty)
    }

    func testEmptyTagNameRejected() {
        XCTAssertThrowsError(try store.upsertTag(named: "   "))
    }

    func testPrivateFlag() throws {
        let entry = try store.create(body: "secret", isPrivate: true)
        XCTAssertTrue(entry.isPrivate)
    }
}
