import SwiftUI

struct VaultSetupView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(VaultManager.self) private var vault

    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var error: String? = nil

    private var canSubmit: Bool {
        pin.count >= 4 && pin == confirmPin
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("vault.setup.title")
                            .font(theme.fontFamily.titleFont)
                            .foregroundStyle(theme.palette.text)
                        Text("vault.setup.warning")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.palette.textMuted)
                            .lineSpacing(4)
                        pinField(title: "vault.pin.new", binding: $pin)
                        pinField(title: "vault.pin.confirm", binding: $confirmPin)
                        if let error {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(Text("vault.setup.nav"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { submit() }
                        .disabled(!canSubmit)
                }
            }
        }
    }

    private func pinField(title: LocalizedStringKey, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(theme.palette.textMuted)
            SecureField("", text: binding)
                .keyboardType(.numberPad)
                .padding(12)
                .background(theme.palette.surface)
        }
    }

    private func submit() {
        do {
            try vault.setupPIN(pin)
            dismiss()
        } catch {
            self.error = "\(error)"
        }
    }
}
