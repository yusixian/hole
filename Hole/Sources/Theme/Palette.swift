import SwiftUI

struct Palette: Equatable, Hashable, Sendable {
    var bg: Color
    var surface: Color
    var accent: Color
    var text: Color
    var textMuted: Color
    var mood: [Color]
    var highlight: Color

    init(
        bg: Color,
        surface: Color,
        accent: Color,
        text: Color,
        textMuted: Color,
        mood: [Color],
        highlight: Color
    ) {
        self.bg = bg
        self.surface = surface
        self.accent = accent
        self.text = text
        self.textMuted = textMuted
        self.mood = mood
        self.highlight = highlight
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
