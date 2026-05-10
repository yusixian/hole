import SwiftUI

enum BuiltInThemes {
    static let washiLight = Theme(
        id: "washi.light",
        displayNameKey: "theme.washi.light",
        appearance: .light,
        fontFamily: .songti,
        texture: .washi,
        palette: Palette(
            bg: Color(hex: 0xF5EDDC),
            surface: Color(hex: 0xFFFAF0),
            accent: Color(hex: 0x7A5A2A),
            text: Color(hex: 0x2C1F0F),
            textMuted: Color(hex: 0x9A7A4A),
            mood: [
                Color(hex: 0xC9A8A8),
                Color(hex: 0xD4C2A0),
                Color(hex: 0x5A7A9A),
                Color(hex: 0xA8B5C9),
                Color(hex: 0xB5C9A8)
            ],
            highlight: Color(hex: 0xF5C04A)
        )
    )

    static let washiDark = Theme(
        id: "washi.dark",
        displayNameKey: "theme.washi.dark",
        appearance: .dark,
        fontFamily: .songti,
        texture: .washi,
        palette: Palette(
            bg: Color(hex: 0x1F1810),
            surface: Color(hex: 0x2A2218),
            accent: Color(hex: 0xE0C088),
            text: Color(hex: 0xF3E9D2),
            textMuted: Color(hex: 0xB39872),
            mood: [
                Color(hex: 0xB07878),
                Color(hex: 0xB89870),
                Color(hex: 0x6E8FAF),
                Color(hex: 0x90A0B5),
                Color(hex: 0x90A878)
            ],
            highlight: Color(hex: 0xF0B040)
        )
    )

    static let newsprintLight = Theme(
        id: "newsprint.light",
        displayNameKey: "theme.newsprint.light",
        appearance: .light,
        fontFamily: .bodoni,
        texture: .newsprint,
        palette: Palette(
            bg: Color(hex: 0xEFE9DA),
            surface: Color(hex: 0xFAF5E6),
            accent: Color(hex: 0x1A1A1A),
            text: Color(hex: 0x141414),
            textMuted: Color(hex: 0x6B6256),
            mood: [
                Color(hex: 0x9A4A4A),
                Color(hex: 0xB08A40),
                Color(hex: 0x3A5A78),
                Color(hex: 0x6E8AA0),
                Color(hex: 0x6A8A4A)
            ],
            highlight: Color(hex: 0xC9A024)
        )
    )

    static let newsprintDark = Theme(
        id: "newsprint.dark",
        displayNameKey: "theme.newsprint.dark",
        appearance: .dark,
        fontFamily: .bodoni,
        texture: .newsprint,
        palette: Palette(
            bg: Color(hex: 0x1B1B1B),
            surface: Color(hex: 0x252525),
            accent: Color(hex: 0xF0E2C0),
            text: Color(hex: 0xEDE5D2),
            textMuted: Color(hex: 0x9A8E78),
            mood: [
                Color(hex: 0xB85A5A),
                Color(hex: 0xB89A4A),
                Color(hex: 0x4A78A0),
                Color(hex: 0x8AA0B8),
                Color(hex: 0x8AB05A)
            ],
            highlight: Color(hex: 0xE8B838)
        )
    )

    static let linenLight = Theme(
        id: "linen.light",
        displayNameKey: "theme.linen.light",
        appearance: .light,
        fontFamily: .pingfangRound,
        texture: .linen,
        palette: Palette(
            bg: Color(hex: 0xF7EFE0),
            surface: Color(hex: 0xFFF7E8),
            accent: Color(hex: 0xC97A3A),
            text: Color(hex: 0x3A2A18),
            textMuted: Color(hex: 0x9A7A56),
            mood: [
                Color(hex: 0xD89E92),
                Color(hex: 0xE8C290),
                Color(hex: 0x88A8C0),
                Color(hex: 0xC0B098),
                Color(hex: 0xA8C09A)
            ],
            highlight: Color(hex: 0xF2A444)
        )
    )

    static let linenDark = Theme(
        id: "linen.dark",
        displayNameKey: "theme.linen.dark",
        appearance: .dark,
        fontFamily: .pingfangRound,
        texture: .linen,
        palette: Palette(
            bg: Color(hex: 0x241810),
            surface: Color(hex: 0x2F2118),
            accent: Color(hex: 0xE89860),
            text: Color(hex: 0xF3E5D0),
            textMuted: Color(hex: 0xB39072),
            mood: [
                Color(hex: 0xC07A6E),
                Color(hex: 0xCFA070),
                Color(hex: 0x6890B0),
                Color(hex: 0xA89878),
                Color(hex: 0x88AA7A)
            ],
            highlight: Color(hex: 0xE89040)
        )
    )

    static let nightInk = Theme(
        id: "nightInk",
        displayNameKey: "theme.nightInk",
        appearance: .dark,
        fontFamily: .songti,
        texture: .nightInk,
        palette: Palette(
            bg: Color(hex: 0x0E1A2A),
            surface: Color(hex: 0x14253A),
            accent: Color(hex: 0xE8C26A),
            text: Color(hex: 0xE8E8E8),
            textMuted: Color(hex: 0x8A9AB0),
            mood: [
                Color(hex: 0xA86A6A),
                Color(hex: 0xB8A06A),
                Color(hex: 0x5A8AB0),
                Color(hex: 0x8AA0C0),
                Color(hex: 0x8AB088)
            ],
            highlight: Color(hex: 0xE8C26A)
        )
    )

    static let defaultLight = Theme(
        id: "default.light",
        displayNameKey: "theme.default.light",
        appearance: .light,
        fontFamily: .system,
        texture: .none,
        palette: Palette(
            bg: Color(.systemBackground),
            surface: Color(.secondarySystemBackground),
            accent: .accentColor,
            text: Color(.label),
            textMuted: Color(.secondaryLabel),
            mood: [
                Color(red: 0.86, green: 0.4, blue: 0.4),
                Color(red: 0.95, green: 0.7, blue: 0.3),
                Color(red: 0.4, green: 0.6, blue: 0.95),
                Color(red: 0.6, green: 0.7, blue: 0.95),
                Color(red: 0.4, green: 0.8, blue: 0.5)
            ],
            highlight: .yellow
        )
    )

    static let defaultDark = Theme(
        id: "default.dark",
        displayNameKey: "theme.default.dark",
        appearance: .dark,
        fontFamily: .system,
        texture: .none,
        palette: Palette(
            bg: Color(.systemBackground),
            surface: Color(.secondarySystemBackground),
            accent: .accentColor,
            text: Color(.label),
            textMuted: Color(.secondaryLabel),
            mood: [
                Color(red: 0.86, green: 0.4, blue: 0.4),
                Color(red: 0.95, green: 0.7, blue: 0.3),
                Color(red: 0.4, green: 0.6, blue: 0.95),
                Color(red: 0.6, green: 0.7, blue: 0.95),
                Color(red: 0.4, green: 0.8, blue: 0.5)
            ],
            highlight: .yellow
        )
    )

    static let all: [Theme] = [
        defaultLight,
        defaultDark,
        washiLight,
        washiDark,
        newsprintLight,
        newsprintDark,
        linenLight,
        linenDark,
        nightInk
    ]
}
