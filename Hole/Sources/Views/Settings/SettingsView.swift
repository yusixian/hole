import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @Environment(ThemeManager.self) private var themeManager
    @State private var showThemePicker = false
    @State private var appLockEnabled: Bool = false

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    MonthMasthead(date: .now)
                    sectionHeader("settings.section.appearance")
                    appearanceCard
                    sectionHeader("settings.section.privacy")
                    privacyCard
                    sectionHeader("settings.section.about")
                    aboutCard
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.system(size: 11, weight: .medium))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(theme.palette.textMuted)
            .padding(.top, 8)
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("settings.theme")
                    .font(theme.fontFamily.bodyFont)
                Spacer()
                Button {
                    showThemePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Text(themeManager.theme(for: .light).displayName)
                            .font(.system(size: 13))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(theme.palette.accent)
                }
            }
            modePicker
        }
        .padding(16)
        .background(theme.palette.surface)
    }

    @ViewBuilder
    private var modePicker: some View {
        @Bindable var mgr = themeManager
        Picker(selection: $mgr.mode) {
            Text("settings.mode.auto").tag(ThemeMode.auto)
            Text("settings.mode.light").tag(ThemeMode.light)
            Text("settings.mode.dark").tag(ThemeMode.dark)
        } label: {
            Text("settings.mode")
        }
        .pickerStyle(.segmented)
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $appLockEnabled) {
                Text("settings.appLock")
                    .font(theme.fontFamily.bodyFont)
            }
            HStack {
                Text("settings.vault")
                    .font(theme.fontFamily.bodyFont)
                Spacer()
                Text("settings.notConfigured")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.palette.textMuted)
            }
        }
        .padding(16)
        .background(theme.palette.surface)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hole")
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Text("settings.about.tagline")
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.textMuted)
            Text(versionString)
                .font(.system(size: 11))
                .foregroundStyle(theme.palette.textMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.surface)
    }

    private var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }
}
