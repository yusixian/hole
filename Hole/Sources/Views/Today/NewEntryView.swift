import SwiftUI
import SwiftData
import PhotosUI

struct NewEntryView: View {
    enum Mode {
        case create
        case edit(Entry)
    }

    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AICoordinator.self) private var aiCoordinator
    @Environment(VaultManager.self) private var vault

    let mode: Mode

    @State private var text: String = ""
    @State private var mood: Mood? = nil
    @State private var tags: [String] = []
    @State private var isPrivate: Bool = false
    @State private var saveError: String? = nil
    @FocusState private var bodyFocused: Bool

    @State private var recorder = AudioRecorder()
    @State private var pendingVoice: PendingVoice? = nil
    @State private var pendingImages: [Data] = []
    @State private var photoSelections: [PhotosPickerItem] = []
    @State private var transcribing: Bool = false

    private struct PendingVoice {
        let url: URL
        let duration: TimeInterval
        var transcript: String
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        bodyEditor
                        sectionHeader("compose.attachments")
                        attachmentBar
                        if !pendingImages.isEmpty { pendingImagesPreview }
                        if let pendingVoice { pendingVoicePreview(pendingVoice) }
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
                        .disabled(saveDisabled)
                }
            }
            .onAppear(perform: loadInitial)
            .onChange(of: photoSelections) { _, newItems in
                Task { await loadPhotoData(newItems) }
            }
        }
    }

    private var saveDisabled: Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty && pendingVoice == nil && pendingImages.isEmpty
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

    private var attachmentBar: some View {
        HStack(spacing: 10) {
            recordButton
            PhotosPicker(
                selection: $photoSelections,
                maxSelectionCount: 4,
                matching: .images
            ) {
                Label("compose.addPhoto", systemImage: "photo")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(theme.palette.text)
                    .overlay(
                        Rectangle().stroke(theme.palette.text, lineWidth: 0.6)
                    )
            }
        }
    }

    @ViewBuilder
    private var recordButton: some View {
        switch recorder.phase {
        case .idle, .failed:
            Button {
                Task { await recorder.start() }
            } label: {
                Label("compose.record", systemImage: "mic")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(theme.palette.text)
                    .overlay(Rectangle().stroke(theme.palette.text, lineWidth: 0.6))
            }
            .buttonStyle(.plain)
        case .recording:
            Button {
                recorder.stop()
                if case let .finished(url, duration) = recorder.phase {
                    Task { await capturePending(url: url, duration: duration) }
                }
            } label: {
                Label(formatTime(recorder.elapsed), systemImage: "stop.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(.red)
            }
            .buttonStyle(.plain)
        case .finished:
            EmptyView()
        }
    }

    private var pendingImagesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(pendingImages.enumerated()), id: \.offset) { index, data in
                    if let img = UIImage(data: data) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                            Button {
                                pendingImages.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .background(Circle().fill(.black.opacity(0.5)))
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func pendingVoicePreview(_ pv: PendingVoice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                Text(formatTime(pv.duration))
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                if transcribing {
                    ProgressView().controlSize(.small)
                }
                Button {
                    pendingVoice = nil
                    try? FileManager.default.removeItem(at: pv.url)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.palette.textMuted)
                }
                .buttonStyle(.plain)
            }
            if !pv.transcript.isEmpty {
                Text(pv.transcript)
                    .font(.system(size: 12))
                    .foregroundStyle(theme.palette.text)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(theme.palette.surface)
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

    private func loadPhotoData(_ items: [PhotosPickerItem]) async {
        var collected: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                collected.append(data)
            }
        }
        await MainActor.run {
            pendingImages.append(contentsOf: collected)
            photoSelections = []
        }
    }

    private func capturePending(url: URL, duration: TimeInterval) async {
        await MainActor.run {
            pendingVoice = PendingVoice(url: url, duration: duration, transcript: "")
            transcribing = true
        }
        let transcript = await SpeechTranscriber.transcribe(url: url)
        await MainActor.run {
            if pendingVoice?.url == url {
                pendingVoice?.transcript = transcript
                if text.isEmpty, !transcript.isEmpty {
                    text = transcript
                }
            }
            transcribing = false
            recorder.reset()
        }
    }

    private func save() {
        let store = EntryStore(context: context, vault: vault)
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
            try persistAttachments(to: savedEntry, store: store)
            aiCoordinator.reflectAfterSave(savedEntry, in: context)
            dismiss()
        } catch {
            saveError = "\(error)"
        }
    }

    private func persistAttachments(to entry: Entry, store: EntryStore) throws {
        if let pv = pendingVoice {
            try store.attachVoice(to: entry, from: pv.url, transcript: pv.transcript, duration: pv.duration)
            pendingVoice = nil
        }
        for data in pendingImages {
            try store.attachImage(to: entry, data: data)
        }
        pendingImages = []
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
