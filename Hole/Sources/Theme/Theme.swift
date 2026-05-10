import SwiftUI

enum Appearance: String, Codable, Sendable, CaseIterable {
    case light, dark
}

enum FontFamily: String, Codable, Sendable, CaseIterable {
    case system
    case songti
    case bodoni
    case pingfangRound

    var titleFont: Font {
        switch self {
        case .system: .system(.largeTitle, design: .default)
        case .songti: .custom("Songti SC", size: 34).weight(.semibold)
        case .bodoni: .custom("Bodoni 72", size: 34)
        case .pingfangRound: .system(.largeTitle, design: .rounded)
        }
    }

    var bodyFont: Font {
        switch self {
        case .system: .system(.body)
        case .songti: .custom("Songti SC", size: 17)
        case .bodoni: .custom("Bodoni 72", size: 17)
        case .pingfangRound: .system(.body, design: .rounded)
        }
    }

    var dropCapFont: Font {
        switch self {
        case .system: .system(size: 64, weight: .light, design: .serif)
        case .songti: .custom("Songti SC", size: 64).weight(.light)
        case .bodoni: .custom("Bodoni 72", size: 64)
        case .pingfangRound: .system(size: 64, weight: .bold, design: .rounded)
        }
    }
}

enum PaperTexture: String, Codable, Sendable, CaseIterable {
    case none
    case washi
    case newsprint
    case linen
    case nightInk
}

struct Theme: Identifiable, Equatable, Sendable {
    var id: String
    var displayNameKey: LocalizedStringResource
    var appearance: Appearance
    var fontFamily: FontFamily
    var texture: PaperTexture
    var palette: Palette

    var displayName: String { String(localized: displayNameKey) }

    static func == (lhs: Theme, rhs: Theme) -> Bool { lhs.id == rhs.id }
}
