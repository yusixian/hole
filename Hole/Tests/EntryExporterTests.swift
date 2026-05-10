import XCTest
import SwiftData
@testable import Hole

@MainActor
final class EntryExporterTests: XCTestCase {
    private var container: ModelContainer!
    private var store: EntryStore!
    private var exporter: EntryExporter!

    override func setUpWithError() throws {
        container = ModelSchema.makeContainer(inMemory: true)
        store = EntryStore(context: container.mainContext)
        exporter = EntryExporter(context: container.mainContext)
    }

    override func tearDownWithError() throws {
        container = nil
        store = nil
        exporter = nil
    }

    func testJSONExportExcludesPrivateByDefault() throws {
        _ = try store.create(body: "public note", mood: .good, tagNames: ["work"])
        _ = try store.create(body: "secret", isPrivate: true)
        let url = try exporter.export(options: .init(includePrivate: false, format: .json))
        let data = try Data(contentsOf: url)
        let str = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(str.contains("public note"))
        XCTAssertFalse(str.contains("secret"))
        XCTAssertTrue(str.contains("work"))
    }

    func testJSONExportIncludesPrivateWhenAsked() throws {
        _ = try store.create(body: "public", mood: .good)
        _ = try store.create(body: "private cleartext", isPrivate: true)
        let url = try exporter.export(options: .init(includePrivate: true, format: .json))
        let data = try Data(contentsOf: url)
        let str = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(str.contains("public"))
        XCTAssertTrue(str.contains("private cleartext"))
    }

    func testMarkdownExportRenders() throws {
        _ = try store.create(body: "Today felt warm", mood: .good, tagNames: ["spring"])
        let url = try exporter.export(options: .init(format: .markdown))
        let data = try Data(contentsOf: url)
        let str = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(str.contains("# Hole export"))
        XCTAssertTrue(str.contains("Today felt warm"))
        XCTAssertTrue(str.contains("`spring`"))
    }

    func testFileExtensionMatchesFormat() throws {
        let json = try exporter.export(options: .init(format: .json))
        let md = try exporter.export(options: .init(format: .markdown))
        XCTAssertTrue(json.lastPathComponent.hasSuffix(".json"))
        XCTAssertTrue(md.lastPathComponent.hasSuffix(".md"))
    }
}
