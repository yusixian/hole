import XCTest
import SwiftData
@testable import Hole

@MainActor
final class EntryStoreVaultTests: XCTestCase {
    private var container: ModelContainer!
    private var vault: VaultManager!
    private var store: EntryStore!

    override func setUpWithError() throws {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "vault.salt")
        defaults.removeObject(forKey: "vault.verifier")
        defaults.removeObject(forKey: "vault.configured")
        container = ModelSchema.makeContainer(inMemory: true)
        vault = VaultManager()
        try vault.setupPIN("1234")
        store = EntryStore(context: container.mainContext, vault: vault)
    }

    override func tearDownWithError() throws {
        vault.reset()
        container = nil
        vault = nil
        store = nil
    }

    func testPrivateEntryEncryptsBodyOnSave() throws {
        let entry = try store.create(body: "shameful secret", isPrivate: true)
        XCTAssertEqual(entry.body, "")
        XCTAssertNotNil(entry.encryptedBlob)
        let plain = try store.decryptIntoMemory(entry)
        XCTAssertEqual(plain, "shameful secret")
    }

    func testNonPrivateEntryNotEncrypted() throws {
        let entry = try store.create(body: "public note", isPrivate: false)
        XCTAssertEqual(entry.body, "public note")
        XCTAssertNil(entry.encryptedBlob)
    }

    func testDecryptThrowsWhenLocked() throws {
        let entry = try store.create(body: "secret", isPrivate: true)
        vault.lock()
        XCTAssertThrowsError(try store.decryptIntoMemory(entry)) { error in
            XCTAssertEqual(error as? VaultManager.VaultError, .locked)
        }
    }

    func testTogglingPrivateOffClearsBlob() throws {
        let entry = try store.create(body: "x", isPrivate: true)
        XCTAssertNotNil(entry.encryptedBlob)
        try store.update(entry, body: "now public", isPrivate: false)
        XCTAssertNil(entry.encryptedBlob)
        XCTAssertEqual(entry.body, "now public")
    }
}
