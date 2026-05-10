import SwiftUI

struct AIEchoCallout: View {
    @Environment(\.theme) private var theme
    let text: String
    var personaName: String = String(localized: "ai.echo.persona.default")

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(theme.palette.accent)
                .frame(width: 2.5)
            VStack(alignment: .leading, spacing: 4) {
                SmallCapsLabel(
                    text: "AI · " + personaName,
                    color: theme.palette.textMuted
                )
                Text(text)
                    .font(theme.fontFamily.bodyFont.italic())
                    .foregroundStyle(theme.palette.text.opacity(0.85))
                    .lineSpacing(3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(theme.palette.accent.opacity(0.06))
    }
}
