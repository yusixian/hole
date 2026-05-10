import SwiftUI

struct ExportView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context

    @State private var format: EntryExporter.Format = .markdown
    @State private var includePrivate: Bool = false
    @State private var resultURL: URL? = nil
    @State private var error: String? = nil

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    sectionHeader("export.format")
                    formatPicker
                    sectionHeader("export.options")
                    privateToggle
                    Button(action: makeExport) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("export.action")
                                .font(theme.fontFamily.bodyFont)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(theme.palette.surface)
                        .background(theme.palette.accent)
                    }
                    .buttonStyle(.plain)
                    if let resultURL {
                        ShareLink(item: resultURL) {
                            HStack {
                                Image(systemName: "tray.and.arrow.up")
                                Text("export.share \(resultURL.lastPathComponent)")
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .foregroundStyle(theme.palette.text)
                            .overlay(
                                Rectangle().stroke(theme.palette.text, lineWidth: 0.6)
                            )
                        }
                    }
                    if let error {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                    Spacer(minLength: 30)
                }
                .padding(20)
            }
        }
        .navigationTitle(Text("export.nav"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.system(size: 11, weight: .medium))
            .tracking(2)
            .textCase(.uppercase)
            .foregroundStyle(theme.palette.textMuted)
    }

    private var formatPicker: some View {
        Picker(selection: $format) {
            ForEach(EntryExporter.Format.allCases) { f in
                Text(String(localized: f.displayKey)).tag(f)
            }
        } label: {
            Text("export.format")
        }
        .pickerStyle(.segmented)
    }

    private var privateToggle: some View {
        Toggle(isOn: $includePrivate) {
            VStack(alignment: .leading, spacing: 2) {
                Text("export.includePrivate")
                    .font(theme.fontFamily.bodyFont)
                Text("export.includePrivate.hint")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.palette.textMuted)
            }
        }
        .padding(12)
        .background(theme.palette.surface)
    }

    private func makeExport() {
        let exporter = EntryExporter(context: context)
        do {
            let url = try exporter.export(options: .init(includePrivate: includePrivate, format: format))
            resultURL = url
            error = nil
        } catch {
            self.error = "\(error)"
        }
    }
}
