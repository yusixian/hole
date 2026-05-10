import XCTest
@testable import Hole

@MainActor
final class VaultManagerTests: XCTestCase {
    private var vault: VaultManager!

    override func setUpWithError() throws {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "vault.salt")
        defaults.removeObject(forKey: "vault.verifier")
        defaults.removeObject(forKey: "vault.configured")
        vault = VaultManager()
    }

    override func tearDownWithError() throws {
        vault.reset()
        vault = nil
    }

    func testInitialState() {
        XCTAssertFalse(vault.isConfigured)
        XCTAssertFalse(vault.isUnlocked)
    }

    func testSetupConfiguresAndUnlocks() throws {
        try vault.setupPIN("1234")
        XCTAssertTrue(vault.isConfigured)
        XCTAssertTrue(vault.isUnlocked)
    }

    func testEncryptRoundtrip() throws {
        try vault.setupPIN("0420")
        let blob = try vault.encryptBody("hello private world")
        let plain = try vault.decryptBody(blob)
        XCTAssertEqual(plain, "hello private world")
    }

    func testUnlockWithCorrectPin() throws {
        try vault.setupPIN("9999")
        vault.lock()
        XCTAssertFalse(vault.isUnlocked)
        try vault.unlock(pin: "9999")
        XCTAssertTrue(vault.isUnlocked)
    }

    func testUnlockWithWrongPinThrows() throws {
        try vault.setupPIN("1111")
        vault.lock()
        XCTAssertThrowsError(try vault.unlock(pin: "2222")) { error in
            XCTAssertEqual(error as? VaultManager.VaultError, .wrongPin)
        }
    }

    func testEncryptWhileLockedThrows() throws {
        try vault.setupPIN("1234")
        vault.lock()
        XCTAssertThrowsError(try vault.encryptBody("oops")) { error in
            XCTAssertEqual(error as? VaultManager.VaultError, .locked)
        }
    }

    func testBackgroundLocks() throws {
        try vault.setupPIN("1234")
        XCTAssertTrue(vault.isUnlocked)
        vault.didEnterBackground()
        XCTAssertFalse(vault.isUnlocked)
    }

    func testResetClearsConfiguration() throws {
        try vault.setupPIN("1234")
        vault.reset()
        XCTAssertFalse(vault.isConfigured)
        XCTAssertFalse(vault.isUnlocked)
    }

    func testCipherTextDiffersBetweenRuns() throws {
        try vault.setupPIN("4242")
        let a = try vault.encryptBody("same plaintext")
        let b = try vault.encryptBody("same plaintext")
        XCTAssertNotEqual(a, b)
    }
}
