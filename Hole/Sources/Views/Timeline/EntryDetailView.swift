import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AICoordinator.self) private var aiCoordinator

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
                    if !entry.body.isEmpty {
                        DropCapText(text: entry.body)
                    }
                    if !entry.imageAttachments.isEmpty {
                        imageGallery
                    }
                    if !entry.voiceAttachments.isEmpty {
                        voiceList
                    }
                    if !entry.tags.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(entry.tags) { tag in
                                PillTag(label: tag.name, isAI: tag.isAI)
                            }
                        }
                    }
                    if aiCoordinator.inFlightEntries.contains(entry.id) && entry.aiEcho == nil {
                        echoLoading
                    } else if let echo = entry.aiEcho {
                        AIEchoCallout(text: echo)
                    }
                    aiSuggestions
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

    private var imageGallery: some View {
        VStack(spacing: 6) {
            ForEach(entry.imageAttachments) { att in
                AttachmentImageView(attachment: att)
            }
        }
    }

    private var voiceList: some View {
        VStack(spacing: 6) {
            ForEach(entry.voiceAttachments) { att in
                AudioPlayerRow(attachment: att)
            }
        }
    }

    private var echoLoading: some View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text("ai.echo.loading")
                .font(.system(size: 11))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(theme.palette.textMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.palette.accent.opacity(0.06))
    }

    @ViewBuilder
    private var aiSuggestions: some View {
        if !entry.aiTagsSuggested.isEmpty || entry.aiMoodSuggested != nil {
            VStack(alignment: .leading, spacing: 8) {
                SmallCapsLabel(text: String(localized: "ai.suggestions"), color: theme.palette.textMuted)
                if let suggestedMood = entry.aiMoodSuggested, entry.mood == nil {
                    Button {
                        entry.mood = suggestedMood
                        try? context.save()
                    } label: {
                        HStack(spacing: 6) {
                            Text(suggestedMood.emoji)
                            Text("ai.suggestion.mood \(suggestedMood.label)")
                                .font(.system(size: 12))
                            Spacer()
                            Image(systemName: "plus.circle")
                        }
                        .padding(10)
                        .foregroundStyle(theme.palette.text)
                        .overlay(
                            Rectangle().stroke(theme.palette.text, style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
                        )
                    }
                    .buttonStyle(.plain)
                }
                if !entry.aiTagsSuggested.isEmpty {
                    let existing = Set(entry.tags.map(\.name))
                    let newSuggested = entry.aiTagsSuggested.filter { !existing.contains($0) }
                    if !newSuggested.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(newSuggested, id: \.self) { name in
                                Button {
                                    acceptTag(name)
                                } label: {
                                    PillTag(label: name, isAI: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func acceptTag(_ name: String) {
        let store = EntryStore(context: context)
        guard let tag = try? store.upsertTag(named: name, isAI: true) else { return }
        if !entry.tags.contains(where: { $0.name == name }) {
            entry.tags.append(tag)
        }
        entry.aiTagsSuggested.removeAll { $0 == name }
        try? context.save()
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
