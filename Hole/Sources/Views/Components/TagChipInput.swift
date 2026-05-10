import SwiftUI

struct TagChipInput: View {
    @Environment(\.theme) private var theme
    @Binding var tags: [String]
    @State private var draft: String = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 6) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    chip(tag, onRemove: { remove(at: index) })
                }
                inputField
            }
        }
    }

    private func chip(_ name: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 12))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(theme.palette.text)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .overlay(
            Rectangle().stroke(theme.palette.text, lineWidth: 0.6)
        )
    }

    private var inputField: some View {
        TextField(
            "tag.input.placeholder",
            text: $draft
        )
        .focused($inputFocused)
        .submitLabel(.done)
        .onSubmit { commitDraft() }
        .font(.system(size: 12))
        .frame(minWidth: 60)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .overlay(
            Rectangle().stroke(theme.palette.textMuted, style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
        )
    }

    private func commitDraft() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !tags.contains(trimmed) {
            tags.append(trimmed)
        }
        draft = ""
        inputFocused = true
    }

    private func remove(at index: Int) {
        guard tags.indices.contains(index) else { return }
        tags.remove(at: index)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let rows = makeRows(in: width, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + (rows.first?.height == 0 ? 0 : spacing) } - (rows.isEmpty ? 0 : spacing)
        let usedWidth = rows.map(\.width).max() ?? 0
        return CGSize(width: min(usedWidth, width), height: max(0, height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(in: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = row.sizes[index]
                subviews[row.indices[index]].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var sizes: [CGSize] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func makeRows(in width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = current.width + (current.indices.isEmpty ? 0 : spacing) + size.width
            if proposedWidth > width, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.indices.append(index)
            current.sizes.append(size)
            current.width += size.width + (current.indices.count > 1 ? spacing : 0)
            current.height = max(current.height, size.height)
        }
        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
