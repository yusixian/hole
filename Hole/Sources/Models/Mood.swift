import Foundation

enum Mood: Int, Codable, CaseIterable, Identifiable, Sendable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case veryGood = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .veryLow: "😞"
        case .low: "🙁"
        case .neutral: "😐"
        case .good: "🙂"
        case .veryGood: "😄"
        }
    }

    var labelKey: String.LocalizationValue {
        switch self {
        case .veryLow: "mood.veryLow"
        case .low: "mood.low"
        case .neutral: "mood.neutral"
        case .good: "mood.good"
        case .veryGood: "mood.veryGood"
        }
    }

    var label: String { String(localized: labelKey) }
}
