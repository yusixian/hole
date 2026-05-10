import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = BuiltInThemes.washiLight
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct ThemedRoot<Content: View>: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(ThemeManager.self) private var themeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        let theme = themeManager.theme(for: systemColorScheme)
        content()
            .environment(\.theme, theme)
            .preferredColorScheme(themeManager.preferredColorScheme)
            .background(theme.palette.bg.ignoresSafeArea())
            .tint(theme.palette.accent)
            .foregroundStyle(theme.palette.text)
    }
}
