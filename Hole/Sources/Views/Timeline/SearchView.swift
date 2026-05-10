import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var filter = EntryFilter()
    @State private var results: [Entry] = []
    @State private var allTags: [Tag] = []

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                VStack(spacing: 0) {
                    searchBar
                    filterChips
                    Divider().background(theme.palette.text.opacity(0.15))
                    resultsList
                }
            }
            .navigationTitle(Text("search.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.done") { dismiss() }
                }
            }
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .task {
                await loadTags()
                refresh()
            }
            .onChange(of: filter) { _, _ in refresh() }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.palette.textMuted)
            TextField("search.placeholder", text: $filter.query)
                .submitLabel(.search)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
            if !filter.query.isEmpty {
                Button { filter.query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.palette.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(theme.palette.surface)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Mood.allCases) { mood in
                    moodChip(mood)
                }
                if !allTags.isEmpty {
                    Rectangle()
                        .fill(theme.palette.text.opacity(0.2))
                        .frame(width: 0.5, height: 18)
                        .padding(.horizontal, 4)
                    ForEach(allTags) { tag in
                        tagChip(tag)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }

    private func moodChip(_ mood: Mood) -> some View {
        let active = filter.moods.contains(mood)
        return Button {
            if active { filter.moods.remove(mood) } else { filter.moods.insert(mood) }
        } label: {
            HStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: 14))
                Text(mood.label)
                    .font(.system(size: 11, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(theme.palette.text)
            .overlay(
                Rectangle().stroke(theme.palette.text, lineWidth: active ? 1.0 : 0.4)
            )
            .background(active ? theme.palette.accent.opacity(0.1) : .clear)
        }
        .buttonStyle(.plain)
    }

    private func tagChip(_ tag: Tag) -> some View {
        let active = filter.tagNames.contains(tag.name)
        return Button {
            if active { filter.tagNames.remove(tag.name) } else { filter.tagNames.insert(tag.name) }
        } label: {
            Text(tag.name)
                .font(.system(size: 11))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .foregroundStyle(theme.palette.text)
                .overlay(
                    Rectangle().stroke(theme.palette.text, lineWidth: active ? 1.0 : 0.4)
                )
                .background(active ? theme.palette.accent.opacity(0.1) : .clear)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var resultsList: some View {
        if results.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(filter.isEmpty ? "search.empty.idle" : "search.empty.noMatch")
                    .font(theme.fontFamily.titleFont)
                    .foregroundStyle(theme.palette.text)
                Text("search.empty.hint")
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.textMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
        } else {
            List {
                ForEach(results) { entry in
                    NavigationLink(value: entry) {
                        resultRow(entry)
                    }
                    .listRowBackground(theme.palette.bg)
                    .listRowSeparatorTint(theme.palette.text.opacity(0.15))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func resultRow(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if let mood = entry.mood {
                    Text(mood.emoji).font(.system(size: 13))
                }
                SmallCapsLabel(text: dateString(entry.createdAt), color: theme.palette.textMuted)
            }
            Text(entry.body)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
                .lineLimit(3)
            if !entry.tags.isEmpty {
                Text(entry.tags.map { "#\($0.name)" }.joined(separator: " "))
                    .font(.system(size: 10))
                    .foregroundStyle(theme.palette.textMuted)
            }
        }
        .padding(.vertical, 4)
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMM d · HH:mm"
        return f.string(from: date)
    }

    private func loadTags() async {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\Tag.name, order: .forward)]
        )
        allTags = (try? context.fetch(descriptor)) ?? []
    }

    private func refresh() {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\Entry.createdAt, order: .reverse)]
        )
        let all = (try? context.fetch(descriptor)) ?? []
        results = all.filter { filter.matches($0) }
    }
}
