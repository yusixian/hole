import SwiftUI
import Observation

enum ThemeMode: String, Codable, Sendable, CaseIterable {
    case auto, light, dark
}

@MainActor
@Observable
final class ThemeManager {
    private static let modeKey = "theme.mode"
    private static let lightIDKey = "theme.lightID"
    private static let darkIDKey = "theme.darkID"

    var mode: ThemeMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Self.modeKey) }
    }

    var lightThemeID: String {
        didSet { UserDefaults.standard.set(lightThemeID, forKey: Self.lightIDKey) }
    }

    var darkThemeID: String {
        didSet { UserDefaults.standard.set(darkThemeID, forKey: Self.darkIDKey) }
    }

    let allThemes: [Theme] = BuiltInThemes.all

    init() {
        let defaults = UserDefaults.standard
        self.mode = ThemeMode(rawValue: defaults.string(forKey: Self.modeKey) ?? "") ?? .auto
        self.lightThemeID = defaults.string(forKey: Self.lightIDKey) ?? BuiltInThemes.washiLight.id
        self.darkThemeID = defaults.string(forKey: Self.darkIDKey) ?? BuiltInThemes.washiDark.id
    }

    func theme(for systemAppearance: ColorScheme) -> Theme {
        let chosenAppearance: Appearance = switch mode {
        case .auto: systemAppearance == .dark ? .dark : .light
        case .light: .light
        case .dark: .dark
        }
        let id = chosenAppearance == .light ? lightThemeID : darkThemeID
        return allThemes.first(where: { $0.id == id && $0.appearance == chosenAppearance })
            ?? (chosenAppearance == .light ? BuiltInThemes.washiLight : BuiltInThemes.washiDark)
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .auto: nil
        case .light: .light
        case .dark: .dark
        }
    }

    func select(_ theme: Theme) {
        switch theme.appearance {
        case .light: lightThemeID = theme.id
        case .dark: darkThemeID = theme.id
        }
    }
}
