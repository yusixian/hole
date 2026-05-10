import SwiftUI

struct DropCapText: View {
    @Environment(\.theme) private var theme
    let text: String
    var minLengthForCap: Int = 30

    private var shouldUseCap: Bool { text.count >= minLengthForCap }

    var body: some View {
        if shouldUseCap, let firstChar = text.first {
            let rest = String(text.dropFirst())
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(firstChar))
                    .font(theme.fontFamily.dropCapFont)
                    .foregroundStyle(theme.palette.accent)
                    .lineLimit(1)
                    .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] - 6 }
                Text(rest)
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.text)
                    .lineSpacing(6)
            }
        } else {
            Text(text)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
                .lineSpacing(6)
        }
    }
}
