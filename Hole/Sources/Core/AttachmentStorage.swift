import Foundation

enum AttachmentStorage {
    static func attachmentsBaseURL() throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let base = docs.appendingPathComponent("Attachments", isDirectory: true)
        if !fm.fileExists(atPath: base.path) {
            try fm.createDirectory(at: base, withIntermediateDirectories: true)
        }
        return base
    }

    static func directory(forEntryID entryID: UUID) throws -> URL {
        let url = try attachmentsBaseURL().appendingPathComponent(entryID.uuidString, isDirectory: true)
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            try fm.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    static func relativePath(for absoluteURL: URL) -> String {
        guard let base = try? attachmentsBaseURL() else { return absoluteURL.lastPathComponent }
        let basePath = base.path
        let absPath = absoluteURL.path
        if absPath.hasPrefix(basePath) {
            return String(absPath.dropFirst(basePath.count + 1))
        }
        return absoluteURL.lastPathComponent
    }

    static func absoluteURL(forRelative path: String) -> URL? {
        guard let base = try? attachmentsBaseURL() else { return nil }
        return base.appendingPathComponent(path)
    }

    @discardableResult
    static func write(_ data: Data, to url: URL) throws -> URL {
        try data.write(to: url, options: [.atomic])
        return url
    }

    @discardableResult
    static func moveTemp(_ tempURL: URL, to destination: URL) throws -> URL {
        let fm = FileManager.default
        if fm.fileExists(atPath: destination.path) {
            try fm.removeItem(at: destination)
        }
        try fm.moveItem(at: tempURL, to: destination)
        return destination
    }
}
