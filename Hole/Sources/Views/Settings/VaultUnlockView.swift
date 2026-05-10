import SwiftUI

struct VaultUnlockView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(VaultManager.self) private var vault

    @State private var pin: String = ""
    @State private var error: String? = nil
    var onUnlocked: () -> Void = {}

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 36))
                        .foregroundStyle(theme.palette.accent)
                    Text("vault.unlock.title")
                        .font(theme.fontFamily.titleFont)
                        .foregroundStyle(theme.palette.text)
                    Text("vault.unlock.subtitle")
                        .font(theme.fontFamily.bodyFont)
                        .foregroundStyle(theme.palette.textMuted)
                    SecureField("vault.pin", text: $pin)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(theme.palette.surface)
                    if let error {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                    Button {
                        attempt()
                    } label: {
                        Text("vault.unlock.action")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(theme.palette.surface)
                            .background(theme.palette.accent)
                    }
                    .buttonStyle(.plain)
                    .disabled(pin.isEmpty)
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(Text("vault.unlock.nav"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
            }
        }
    }

    private func attempt() {
        do {
            try vault.unlock(pin: pin)
            onUnlocked()
            dismiss()
        } catch {
            self.error = "\(error)"
        }
    }
}
