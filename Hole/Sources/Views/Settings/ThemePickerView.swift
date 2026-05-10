import SwiftUI

struct ThemePickerView: View {
    @Environment(\.theme) private var currentTheme
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedAppearance: Appearance = .light

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: currentTheme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        appearanceTabs
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filteredThemes) { theme in
                                themeCard(theme)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(Text("settings.theme"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.done") { dismiss() }
                }
            }
        }
    }

    private var filteredThemes: [Theme] {
        themeManager.allThemes.filter { $0.appearance == selectedAppearance }
    }

    private var appearanceTabs: some View {
        Picker(selection: $selectedAppearance) {
            Text("appearance.light").tag(Appearance.light)
            Text("appearance.dark").tag(Appearance.dark)
        } label: {
            Text("appearance")
        }
        .pickerStyle(.segmented)
    }

    private var currentSelectedID: String {
        switch selectedAppearance {
        case .light: themeManager.lightThemeID
        case .dark: themeManager.darkThemeID
        }
    }

    private func themeCard(_ theme: Theme) -> some View {
        let isSelected = theme.id == currentSelectedID
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Circle().fill(theme.palette.bg).frame(width: 10, height: 10)
                Circle().fill(theme.palette.surface).frame(width: 10, height: 10)
                Circle().fill(theme.palette.accent).frame(width: 10, height: 10)
                Circle().fill(theme.palette.text).frame(width: 10, height: 10)
                Circle().fill(theme.palette.textMuted).frame(width: 10, height: 10)
                ForEach(theme.palette.mood.indices, id: \.self) { i in
                    Circle().fill(theme.palette.mood[i]).frame(width: 8, height: 8)
                }
            }
            Text(theme.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.palette.text)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.bg)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? theme.palette.accent : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            themeManager.select(theme)
        }
    }
}
