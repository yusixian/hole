import SwiftUI

struct AppLockGate<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(AppLockManager.self) private var appLock
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
                .blur(radius: appLock.isLocked ? 24 : 0)
                .allowsHitTesting(!appLock.isLocked)
            if appLock.isLocked {
                lockOverlay
            }
        }
        .task {
            if appLock.isEnabled && appLock.isLocked {
                await appLock.unlock()
            }
        }
    }

    private var lockOverlay: some View {
        ZStack {
            theme.palette.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(theme.palette.accent)
                Text("applock.title")
                    .font(theme.fontFamily.titleFont)
                    .foregroundStyle(theme.palette.text)
                Text("applock.subtitle")
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button {
                    Task { await appLock.unlock() }
                } label: {
                    Label("applock.unlock", systemImage: "faceid")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .foregroundStyle(theme.palette.surface)
                        .background(theme.palette.accent)
                }
                .buttonStyle(.plain)
                if let err = appLock.lastError {
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
