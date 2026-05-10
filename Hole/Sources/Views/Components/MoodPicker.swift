import SwiftUI

struct MoodPicker: View {
    @Environment(\.theme) private var theme
    @Binding var selection: Mood?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Mood.allCases) { mood in
                let isSelected = selection == mood
                Button {
                    selection = isSelected ? nil : mood
                } label: {
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 26))
                        Circle()
                            .fill(theme.palette.mood[safe: mood.rawValue - 1] ?? theme.palette.accent)
                            .frame(width: 6, height: 6)
                            .opacity(isSelected ? 1 : 0)
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Rectangle()
                            .stroke(theme.palette.text, lineWidth: isSelected ? 1.0 : 0.4)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
