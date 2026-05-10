import SwiftUI
import SwiftData

struct NewEntryView: View {
    enum Mode {
        case create
        case edit(Entry)
    }

    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AICoordinator.self) private var aiCoordinator

    let mode: Mode

    @State private var text: String = ""
    @State private var mood: Mood? = nil
    @State private var tags: [String] = []
    @State private var isPrivate: Bool = false
    @State private var saveError: String? = nil
    @FocusState private var bodyFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        bodyEditor
                        sectionHeader("compose.mood")
                        MoodPicker(selection: $mood)
                        sectionHeader("compose.tags")
                        TagChipInput(tags: $tags)
                        sectionHeader("compose.privacy")
                        privateToggle
                        if let saveError {
                            Text(saveError)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(Text(navTitleKey))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadInitial)
        }
    }

    private var navTitleKey: LocalizedStringKey {
        switch mode {
        case .create: "compose.title.new"
        case .edit: "compose.title.edit"
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.system(size: 11, weight: .medium))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(theme.palette.textMuted)
    }

    private var bodyEditor: some View {
        TextEditor(text: $text)
            .focused($bodyFocused)
            .scrollContentBackground(.hidden)
            .font(theme.fontFamily.bodyFont)
            .foregroundStyle(theme.palette.text)
            .frame(minHeight: 200)
            .padding(12)
            .background(theme.palette.surface)
            .overlay(
                Rectangle().stroke(theme.palette.text.opacity(0.08), lineWidth: 0.5)
            )
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text("compose.body.placeholder")
                        .font(theme.fontFamily.bodyFont)
                        .foregroundStyle(theme.palette.textMuted)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
    }

    private var privateToggle: some View {
        Toggle(isOn: $isPrivate) {
            HStack(spacing: 6) {
                Image(systemName: isPrivate ? "lock.fill" : "lock.open")
                Text("compose.private")
                    .font(theme.fontFamily.bodyFont)
            }
        }
        .padding(12)
        .background(theme.palette.surface)
    }

    private func loadInitial() {
        guard case let .edit(entry) = mode else {
            bodyFocused = true
            return
        }
        text = entry.body
        mood = entry.mood
        tags = entry.tags.map(\.name)
        isPrivate = entry.isPrivate
    }

    private func save() {
        let store = EntryStore(context: context)
        do {
            let savedEntry: Entry
            switch mode {
            case .create:
                savedEntry = try store.create(body: text, mood: mood, tagNames: tags, isPrivate: isPrivate)
            case .edit(let entry):
                try store.update(entry, body: text, mood: .some(mood), tagNames: tags, isPrivate: isPrivate)
                aiCoordinator.clearInsights(on: entry)
                savedEntry = entry
            }
            aiCoordinator.reflectAfterSave(savedEntry, in: context)
            dismiss()
        } catch {
            saveError = "\(error)"
        }
    }
}
