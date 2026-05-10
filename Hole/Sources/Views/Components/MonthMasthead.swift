import SwiftUI

struct MonthMasthead: View {
    @Environment(\.theme) private var theme
    let date: Date

    private var monthString: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "yyyy · MMMM"
        return f.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SmallCapsLabel(text: String(localized: "masthead.section"), color: theme.palette.textMuted)
            Text(monthString)
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Rectangle()
                .fill(theme.palette.text)
                .frame(height: 1)
                .padding(.top, 2)
            Rectangle()
                .fill(theme.palette.text.opacity(0.3))
                .frame(height: 0.5)
                .padding(.top, 2)
        }
    }
}
