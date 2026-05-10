import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.theme) private var theme
    @Environment(OnboardingState.self) private var onboarding
    @Environment(AppLockManager.self) private var appLock
    @Environment(AICoordinator.self) private var aiCoordinator
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\Persona.sortOrder, order: .forward)])
    private var personas: [Persona]

    @State private var pageIndex: Int = 0
    @State private var enableAppLock: Bool = false
    @State private var selectedPersonaID: String = "listener"

    private var pageCount: Int { 5 }

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            VStack {
                TabView(selection: $pageIndex) {
                    welcomePage.tag(0)
                    featuresPage.tag(1)
                    aiPage.tag(2)
                    privacyPage.tag(3)
                    setupPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                bottomBar
            }
        }
        .interactiveDismissDisabled()
    }

    private var welcomePage: some View {
        page(
            icon: "leaf.circle.fill",
            titleKey: "onboarding.welcome.title",
            bodyKey: "onboarding.welcome.body"
        )
    }

    private var featuresPage: some View {
        page(
            icon: "square.and.pencil",
            titleKey: "onboarding.features.title",
            bodyKey: "onboarding.features.body"
        )
    }

    private var aiPage: some View {
        page(
            icon: "ear",
            titleKey: "onboarding.ai.title",
            bodyKey: "onboarding.ai.body"
        )
    }

    private var privacyPage: some View {
        page(
            icon: "lock.shield",
            titleKey: "onboarding.privacy.title",
            bodyKey: "onboarding.privacy.body"
        )
    }

    private var setupPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(theme.palette.accent)
                Text("onboarding.setup.title")
                    .font(theme.fontFamily.titleFont)
                    .foregroundStyle(theme.palette.text)
                Text("onboarding.setup.body")
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.textMuted)
                    .lineSpacing(4)

                if appLock.biometryAvailable {
                    Toggle(isOn: $enableAppLock) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("onboarding.setup.appLock")
                                .font(theme.fontFamily.bodyFont)
                            Text("onboarding.setup.appLock.hint")
                                .font(.system(size: 11))
                                .foregroundStyle(theme.palette.textMuted)
                        }
                    }
                    .padding(12)
                    .background(theme.palette.surface)
                }

                if !personas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("onboarding.setup.persona")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(2)
                            .textCase(.uppercase)
                            .foregroundStyle(theme.palette.textMuted)
                        ForEach(personas) { persona in
                            personaRow(persona)
                        }
                    }
                }
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 28)
            .padding(.top, 40)
        }
    }

    private func personaRow(_ persona: Persona) -> some View {
        let active = selectedPersonaID == persona.id
        return Button {
            selectedPersonaID = persona.id
        } label: {
            HStack(spacing: 10) {
                Image(systemName: persona.avatarSymbol)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(theme.palette.accent)
                Text(persona.name)
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.text)
                Spacer()
                if active {
                    Image(systemName: "checkmark")
                        .foregroundStyle(theme.palette.accent)
                }
            }
            .padding(12)
            .background(active ? theme.palette.accent.opacity(0.08) : theme.palette.surface)
            .overlay(
                Rectangle().stroke(theme.palette.text.opacity(active ? 0.4 : 0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func page(icon: String, titleKey: LocalizedStringKey, bodyKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(theme.palette.accent)
            Text(titleKey)
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Text(bodyKey)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.textMuted)
                .lineSpacing(4)
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomBar: some View {
        HStack {
            Button {
                pageIndex = max(0, pageIndex - 1)
            } label: {
                Text("onboarding.back")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.palette.textMuted)
            }
            .opacity(pageIndex == 0 ? 0 : 1)
            .disabled(pageIndex == 0)
            Spacer()
            Button {
                advanceOrFinish()
            } label: {
                Text(pageIndex == pageCount - 1 ? "onboarding.start" : "onboarding.next")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .foregroundStyle(theme.palette.surface)
                    .background(theme.palette.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }

    private func advanceOrFinish() {
        if pageIndex < pageCount - 1 {
            pageIndex += 1
        } else {
            Task { await finish() }
        }
    }

    private func finish() async {
        if enableAppLock {
            await appLock.enable()
        }
        aiCoordinator.activePersonaID = selectedPersonaID
        onboarding.markCompleted()
    }
}
