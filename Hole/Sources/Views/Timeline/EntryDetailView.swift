import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let entry: Entry
    @State private var showEdit: Bool = false
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    Divider()
                        .background(theme.palette.text.opacity(0.2))
                    if entry.isPrivate {
                        privateBanner
                    }
                    DropCapText(text: entry.body)
                    if !entry.tags.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(entry.tags) { tag in
                                PillTag(label: tag.name, isAI: tag.isAI)
                            }
                        }
                    }
                    if let echo = entry.aiEcho {
                        AIEchoCallout(text: echo)
                    }
                    Spacer(minLength: 30)
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEdit = true
                    } label: {
                        Label("common.edit", systemImage: "square.and.pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("common.delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            NewEntryView(mode: .edit(entry))
        }
        .confirmationDialog(
            Text("entry.delete.confirm"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("common.delete", role: .destructive) {
                deleteAndPop()
            }
            Button("common.cancel", role: .cancel) {}
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            SmallCapsLabel(text: dateString, color: theme.palette.textMuted)
            HStack(spacing: 10) {
                if let mood = entry.mood {
                    HStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 18))
                        Text(mood.label)
                            .font(.system(size: 12))
                            .foregroundStyle(theme.palette.textMuted)
                    }
                }
            }
        }
    }

    private var privateBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
            Text("entry.private.banner")
                .font(.system(size: 12))
        }
        .foregroundStyle(theme.palette.textMuted)
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle().stroke(theme.palette.textMuted, style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
        )
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "yyyy-MM-dd · HH:mm"
        return f.string(from: entry.createdAt)
    }

    private func deleteAndPop() {
        let store = EntryStore(context: context)
        try? store.delete(entry)
        dismiss()
    }
}
