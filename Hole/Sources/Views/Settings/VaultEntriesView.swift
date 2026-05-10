import SwiftUI
import SwiftData

struct VaultEntriesView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(VaultManager.self) private var vault

    @Query(
        filter: #Predicate<Entry> { $0.isPrivate },
        sort: [SortDescriptor(\Entry.createdAt, order: .reverse)]
    )
    private var privateEntries: [Entry]

    @State private var showUnlock: Bool = false
    @State private var decryptedCache: [UUID: String] = [:]

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            if vault.isUnlocked {
                listView
            } else {
                lockedView
            }
        }
        .navigationTitle(Text("vault.entries.nav"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vault.isUnlocked {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("vault.lock.action") {
                        vault.lock()
                        decryptedCache = [:]
                    }
                }
            }
        }
        .sheet(isPresented: $showUnlock) {
            VaultUnlockView()
        }
        .onAppear { reloadDecryptedIfNeeded() }
        .onChange(of: vault.isUnlocked) { _, unlocked in
            if unlocked { reloadDecryptedIfNeeded() }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 40))
                .foregroundStyle(theme.palette.accent)
            Text("vault.entries.locked")
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Button {
                showUnlock = true
            } label: {
                Text("vault.unlock.action")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundStyle(theme.palette.surface)
                    .background(theme.palette.accent)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var listView: some View {
        if privateEntries.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("vault.entries.empty")
                    .font(theme.fontFamily.titleFont)
                    .foregroundStyle(theme.palette.text)
                Text("vault.entries.empty.hint")
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.textMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
        } else {
            List {
                ForEach(privateEntries) { entry in
                    row(entry)
                        .listRowBackground(theme.palette.bg)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func row(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(theme.palette.textMuted)
                SmallCapsLabel(text: dateString(entry.createdAt), color: theme.palette.textMuted)
                if let mood = entry.mood {
                    Text(mood.emoji).font(.system(size: 13))
                }
            }
            Text(decryptedCache[entry.id] ?? entry.body)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
                .lineLimit(4)
        }
        .padding(.vertical, 4)
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMM d · HH:mm"
        return f.string(from: date)
    }

    private func reloadDecryptedIfNeeded() {
        guard vault.isUnlocked else { return }
        var next: [UUID: String] = [:]
        for entry in privateEntries {
            if let blob = entry.encryptedBlob {
                if let plain = try? vault.decryptBody(blob) {
                    next[entry.id] = plain
                }
            }
        }
        decryptedCache = next
    }
}
