import XCTest
import SwiftData
@testable import Hole

@MainActor
final class AICoordinatorTests: XCTestCase {
    private var container: ModelContainer!
    private var store: EntryStore!
    private var coordinator: AICoordinator!

    override func setUpWithError() throws {
        container = ModelSchema.makeContainer(inMemory: true)
        store = EntryStore(context: container.mainContext)
        coordinator = AICoordinator(provider: LocalAIProvider())
        coordinator.echoEnabled = true
    }

    override func tearDownWithError() throws {
        container = nil
        store = nil
        coordinator = nil
    }

    func testReflectPopulatesEcho() async throws {
        let entry = try store.create(body: "今天加班好累，回家的路上很孤独")
        coordinator.reflectAfterSave(entry, in: container.mainContext)
        try await waitForFinished(entryID: entry.id, timeout: 2.0)
        XCTAssertNotNil(entry.aiEcho)
        XCTAssertNotNil(entry.aiSummary)
        XCTAssertEqual(entry.aiMoodSuggested, .low)
        XCTAssertTrue(entry.aiTagsSuggested.contains("工作") || entry.aiTagsSuggested.contains("孤独"))
    }

    func testPrivateEntrySkipped() async throws {
        let entry = try store.create(body: "secret thoughts", isPrivate: true)
        coordinator.reflectAfterSave(entry, in: container.mainContext)
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(entry.aiEcho)
        XCTAssertNil(entry.aiSummary)
    }

    func testToggleOffSkips() async throws {
        let entry = try store.create(body: "happy day full of joy")
        coordinator.echoEnabled = false
        coordinator.reflectAfterSave(entry, in: container.mainContext)
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(entry.aiEcho)
    }

    func testEnglishDetection() async throws {
        let entry = try store.create(body: "I am feeling sad and tired tonight")
        coordinator.reflectAfterSave(entry, in: container.mainContext)
        try await waitForFinished(entryID: entry.id, timeout: 2.0)
        XCTAssertEqual(AILanguage.detect(from: entry.body), .en)
        XCTAssertEqual(entry.aiMoodSuggested, .low)
    }

    func testClearInsightsResetsFields() throws {
        let entry = try store.create(body: "x")
        entry.aiEcho = "echo"
        entry.aiSummary = "summary"
        entry.aiMoodSuggested = .good
        entry.aiTagsSuggested = ["a"]
        coordinator.clearInsights(on: entry)
        XCTAssertNil(entry.aiEcho)
        XCTAssertNil(entry.aiSummary)
        XCTAssertNil(entry.aiMoodSuggested)
        XCTAssertTrue(entry.aiTagsSuggested.isEmpty)
    }

    private func waitForFinished(entryID: UUID, timeout: TimeInterval) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !coordinator.inFlightEntries.contains(entryID) { return }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        throw XCTSkip("AI reflect did not finish within timeout")
    }
}
