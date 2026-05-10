import SwiftUI
import SwiftData

enum SettingsRoute: Hashable {
    case vaultEntries
}

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @Environment(ThemeManager.self) private var themeManager
    @Environment(AICoordinator.self) private var aiCoordinator
    @Environment(AppLockManager.self) private var appLock
    @Environment(VaultManager.self) private var vault
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Persona.sortOrder, order: .forward)])
    private var personas: [Persona]
    @State private var showThemePicker = false
    @State private var showVaultSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        MonthMasthead(date: .now)
                        sectionHeader("settings.section.appearance")
                        appearanceCard
                        sectionHeader("settings.section.ai")
                        aiCard
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
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .vaultEntries: VaultEntriesView()
                }
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
            }
            .sheet(isPresented: $showVaultSetup) {
                VaultSetupView()
            }
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

    @ViewBuilder
    private var aiCard: some View {
        @Bindable var coord = aiCoordinator
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $coord.echoEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.ai.echo")
                        .font(theme.fontFamily.bodyFont)
                    Text("settings.ai.echo.hint")
                        .font(.system(size: 11))
                        .foregroundStyle(theme.palette.textMuted)
                }
            }
            personaPicker
        }
        .padding(16)
        .background(theme.palette.surface)
    }

    @ViewBuilder
    private var personaPicker: some View {
        @Bindable var coord = aiCoordinator
        if !personas.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("settings.ai.persona")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundStyle(theme.palette.textMuted)
                Picker(selection: $coord.activePersonaID) {
                    ForEach(personas) { persona in
                        Text(persona.name).tag(persona.id)
                    }
                } label: {
                    Text("settings.ai.persona")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    @ViewBuilder
    private var privacyCard: some View {
        @Bindable var lock = appLock
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { lock.isEnabled },
                set: { newValue in
                    Task {
                        if newValue {
                            await lock.enable()
                        } else {
                            lock.disable()
                        }
                    }
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.appLock")
                        .font(theme.fontFamily.bodyFont)
                    if !lock.biometryAvailable {
                        Text("settings.appLock.unavailable")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.palette.textMuted)
                    }
                }
            }
            .disabled(!appLock.biometryAvailable)

            Divider().background(theme.palette.text.opacity(0.1))

            if vault.isConfigured {
                NavigationLink(value: SettingsRoute.vaultEntries) {
                    HStack {
                        Text("settings.vault.entries")
                            .font(theme.fontFamily.bodyFont)
                        Spacer()
                        Text(vault.isUnlocked ? "vault.state.unlocked" : "vault.state.locked")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.palette.textMuted)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(theme.palette.textMuted)
                    }
                }
                .buttonStyle(.plain)
                Button(role: .destructive) {
                    vault.reset()
                } label: {
                    Text("settings.vault.reset")
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                }
            } else {
                Button {
                    showVaultSetup = true
                } label: {
                    HStack {
                        Text("settings.vault.setup")
                            .font(theme.fontFamily.bodyFont)
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                    .foregroundStyle(theme.palette.text)
                }
                .buttonStyle(.plain)
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
