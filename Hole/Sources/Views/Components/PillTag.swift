import SwiftUI

struct PillTag: View {
    @Environment(\.theme) private var theme
    let label: String
    var isAI: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if isAI {
                Text("+ AI")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1.5)
            }
            Text(label)
                .font(.system(size: 11, weight: .regular))
        }
        .foregroundStyle(theme.palette.text)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .overlay {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(
                    theme.palette.text,
                    style: StrokeStyle(lineWidth: 0.6, dash: isAI ? [3, 2] : [])
                )
        }
    }
}
