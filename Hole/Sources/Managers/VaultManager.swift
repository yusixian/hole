import Foundation
import CryptoKit
import Observation

@MainActor
@Observable
final class VaultManager {
    private static let saltKey = "vault.salt"
    private static let verifierKey = "vault.verifier"
    private static let configuredKey = "vault.configured"

    enum VaultError: Error, LocalizedError {
        case notConfigured
        case wrongPin
        case locked
        case decryptFailed
        case encodingFailed

        var errorDescription: String? {
            switch self {
            case .notConfigured: "Vault not configured"
            case .wrongPin: "Wrong PIN"
            case .locked: "Vault is locked"
            case .decryptFailed: "Decrypt failed"
            case .encodingFailed: "Encoding failed"
            }
        }
    }

    private(set) var isConfigured: Bool
    private(set) var isUnlocked: Bool = false
    private var sessionKey: SymmetricKey?
    private var lastUnlockedAt: Date?

    init() {
        self.isConfigured = UserDefaults.standard.bool(forKey: Self.configuredKey)
    }

    func setupPIN(_ pin: String) throws {
        guard !pin.isEmpty else { throw VaultError.wrongPin }
        let salt = Self.randomBytes(16)
        let key = Self.deriveKey(pin: pin, salt: salt)
        let verifier = Self.makeVerifier(key: key)
        let defaults = UserDefaults.standard
        defaults.set(salt, forKey: Self.saltKey)
        defaults.set(verifier, forKey: Self.verifierKey)
        defaults.set(true, forKey: Self.configuredKey)
        isConfigured = true
        sessionKey = key
        isUnlocked = true
        lastUnlockedAt = .now
    }

    func unlock(pin: String) throws {
        guard isConfigured,
              let salt = UserDefaults.standard.data(forKey: Self.saltKey),
              let storedVerifier = UserDefaults.standard.data(forKey: Self.verifierKey)
        else { throw VaultError.notConfigured }
        let key = Self.deriveKey(pin: pin, salt: salt)
        let candidate = Self.makeVerifier(key: key)
        guard storedVerifier == candidate else { throw VaultError.wrongPin }
        sessionKey = key
        isUnlocked = true
        lastUnlockedAt = .now
    }

    func lock() {
        sessionKey = nil
        isUnlocked = false
    }

    func reset() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Self.saltKey)
        defaults.removeObject(forKey: Self.verifierKey)
        defaults.set(false, forKey: Self.configuredKey)
        sessionKey = nil
        isUnlocked = false
        isConfigured = false
    }

    func didEnterBackground() {
        guard isConfigured else { return }
        lock()
    }

    func encryptBody(_ plain: String) throws -> Data {
        guard let key = sessionKey else { throw VaultError.locked }
        guard let plainData = plain.data(using: .utf8) else { throw VaultError.encodingFailed }
        let sealed = try AES.GCM.seal(plainData, using: key)
        guard let combined = sealed.combined else { throw VaultError.encodingFailed }
        return combined
    }

    func decryptBody(_ blob: Data) throws -> String {
        guard let key = sessionKey else { throw VaultError.locked }
        do {
            let box = try AES.GCM.SealedBox(combined: blob)
            let opened = try AES.GCM.open(box, using: key)
            guard let str = String(data: opened, encoding: .utf8) else {
                throw VaultError.decryptFailed
            }
            return str
        } catch {
            throw VaultError.decryptFailed
        }
    }

    private static func deriveKey(pin: String, salt: Data) -> SymmetricKey {
        let pinData = Data(pin.utf8)
        let prk = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: pinData),
            salt: salt,
            info: Data("hole.vault.v1".utf8),
            outputByteCount: 32
        )
        return prk
    }

    private static func makeVerifier(key: SymmetricKey) -> Data {
        let payload = Data("verifier".utf8)
        let mac = HMAC<SHA256>.authenticationCode(for: payload, using: key)
        return Data(mac)
    }

    private static func randomBytes(_ count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }
}
