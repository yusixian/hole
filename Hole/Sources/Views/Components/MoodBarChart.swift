import SwiftUI

struct MoodBarChart: View {
    @Environment(\.theme) private var theme
    let counts: [Int]
    var selected: Int? = nil
    var maxBarHeight: CGFloat = 60

    private var maxValue: Int { max(1, counts.max() ?? 1) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(counts.enumerated()), id: \.offset) { index, value in
                let height = maxBarHeight * CGFloat(value) / CGFloat(maxValue)
                let isSelected = selected == index
                let color = theme.palette.mood[safe: index] ?? theme.palette.accent
                Rectangle()
                    .fill(color)
                    .frame(width: isSelected ? 14 : 10, height: max(2, height))
                    .opacity(isSelected ? 1 : 0.85)
            }
            Text("\((selected ?? 0) + 1)/\(counts.count)")
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
                .padding(.leading, 6)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
