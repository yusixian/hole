import Foundation
import SwiftData

@MainActor
struct EntryExporter {
    let context: ModelContext

    enum Format: String, CaseIterable, Identifiable, Sendable {
        case json
        case markdown

        var id: String { rawValue }

        var fileExtension: String {
            switch self {
            case .json: "json"
            case .markdown: "md"
            }
        }

        var displayKey: String.LocalizationValue {
            switch self {
            case .json: "export.format.json"
            case .markdown: "export.format.markdown"
            }
        }
    }

    struct Options: Sendable {
        var includePrivate: Bool = false
        var format: Format = .markdown
    }

    private struct EntryDTO: Codable {
        let id: UUID
        let createdAt: Date
        let updatedAt: Date
        let body: String
        let mood: Int?
        let isPrivate: Bool
        let tags: [String]
        let aiEcho: String?
        let aiSummary: String?
    }

    func export(options: Options = Options()) throws -> URL {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        let all = try context.fetch(descriptor)
        let filtered = options.includePrivate ? all : all.filter { !$0.isPrivate }

        let data: Data
        switch options.format {
        case .json:
            data = try makeJSON(entries: filtered)
        case .markdown:
            data = makeMarkdown(entries: filtered)
        }

        let dir = FileManager.default.temporaryDirectory
        let stamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
        let url = dir.appendingPathComponent("hole-export-\(stamp).\(options.format.fileExtension)")
        try data.write(to: url, options: [.atomic])
        return url
    }

    private func makeJSON(entries: [Entry]) throws -> Data {
        let dtos = entries.map { entry in
            EntryDTO(
                id: entry.id,
                createdAt: entry.createdAt,
                updatedAt: entry.updatedAt,
                body: entry.isPrivate && entry.encryptedBlob != nil ? "" : entry.body,
                mood: entry.moodRaw,
                isPrivate: entry.isPrivate,
                tags: entry.tags.map(\.name),
                aiEcho: entry.aiEcho,
                aiSummary: entry.aiSummary
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(dtos)
    }

    private func makeMarkdown(entries: [Entry]) -> Data {
        var out = "# Hole export\n\n"
        let f = ISO8601DateFormatter()
        out += "Generated: \(f.string(from: .now))\n\n"
        out += "Total entries: \(entries.count)\n\n---\n\n"
        for entry in entries {
            out += "## \(f.string(from: entry.createdAt))\n\n"
            if let mood = entry.mood {
                out += "**Mood:** \(mood.emoji) \(mood.label)\n\n"
            }
            if !entry.tags.isEmpty {
                out += "**Tags:** \(entry.tags.map { "`\($0.name)`" }.joined(separator: " "))\n\n"
            }
            if entry.isPrivate {
                out += "_Private entry — body omitted from non-encrypted export._\n\n"
            } else {
                out += "\(entry.body)\n\n"
            }
            if let echo = entry.aiEcho {
                out += "> _AI echo:_ \(echo)\n\n"
            }
            if let summary = entry.aiSummary {
                out += "> _Summary:_ \(summary)\n\n"
            }
            out += "---\n\n"
        }
        return Data(out.utf8)
    }
}
