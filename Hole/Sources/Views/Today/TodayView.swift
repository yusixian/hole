import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context

    @Query(
        filter: #Predicate<Entry> { !$0.isPrivate },
        sort: [SortDescriptor(\Entry.createdAt, order: .reverse)]
    )
    private var recentEntries: [Entry]

    private var todayEntries: [Entry] {
        let cal = Calendar.current
        return recentEntries.filter { cal.isDateInToday($0.createdAt) }
    }

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    MonthMasthead(date: .now)
                    if todayEntries.isEmpty {
                        emptyTodayCard
                    } else {
                        ForEach(todayEntries) { entry in
                            todayEntryCard(entry)
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }

    private var emptyTodayCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SmallCapsLabel(text: String(localized: "today.section"), color: theme.palette.textMuted)
            Text("today.empty.title")
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Text("today.empty.subtitle")
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.textMuted)
            HStack(spacing: 10) {
                quickAction("today.action.write", icon: "square.and.pencil")
                quickAction("today.action.voice", icon: "mic")
                quickAction("today.action.photo", icon: "photo")
            }
            .padding(.top, 6)
        }
        .padding(18)
        .background(theme.palette.surface)
        .overlay(
            Rectangle()
                .stroke(theme.palette.text.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: theme.palette.text.opacity(0.06), radius: 4, y: 2)
    }

    private func todayEntryCard(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SmallCapsLabel(text: timeString(entry.createdAt), color: theme.palette.textMuted)
            DropCapText(text: entry.body)
            if let echo = entry.aiEcho {
                AIEchoCallout(text: echo)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.surface)
        .shadow(color: theme.palette.text.opacity(0.05), radius: 4, y: 2)
    }

    private func quickAction(_ titleKey: LocalizedStringKey, icon: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(titleKey)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(theme.palette.text)
            .overlay(
                Rectangle()
                    .stroke(theme.palette.text, lineWidth: 0.6)
            )
        }
        .buttonStyle(.plain)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
