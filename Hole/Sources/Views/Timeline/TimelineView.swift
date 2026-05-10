import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.theme) private var theme

    @Query(
        filter: #Predicate<Entry> { !$0.isPrivate },
        sort: [SortDescriptor(\Entry.createdAt, order: .reverse)]
    )
    private var entries: [Entry]

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(theme: theme)
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        MonthMasthead(date: .now)
                        weeklyMoodStrip
                        if entries.isEmpty {
                            emptyState
                        } else {
                            timelineFeed
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }

    private var weeklyMoodStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            SmallCapsLabel(text: String(localized: "timeline.weekMood"), color: theme.palette.textMuted)
            MoodBarChart(counts: weekCounts())
        }
    }

    private func weekCounts() -> [Int] {
        var counts = [Int](repeating: 0, count: 5)
        let cal = Calendar.current
        let weekAgo = cal.date(byAdding: .day, value: -7, to: .now) ?? .now
        for entry in entries where entry.createdAt > weekAgo {
            if let m = entry.mood {
                counts[m.rawValue - 1] += 1
            }
        }
        return counts
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("timeline.empty.title")
                .font(theme.fontFamily.titleFont)
                .foregroundStyle(theme.palette.text)
            Text("timeline.empty.subtitle")
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.textMuted)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.palette.surface)
    }

    private var timelineFeed: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(grouped, id: \.0) { group in
                Text(group.0)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(theme.palette.textMuted)
                    .textCase(.uppercase)
                    .padding(.top, 8)
                Rectangle()
                    .fill(theme.palette.text.opacity(0.2))
                    .frame(height: 0.5)
                ForEach(group.1) { entry in
                    NavigationLink(value: entry) {
                        entryRow(entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var grouped: [(String, [Entry])] {
        let cal = Calendar.current
        var buckets: [(String, [Entry])] = []
        for entry in entries {
            let key: String
            if cal.isDateInToday(entry.createdAt) {
                key = String(localized: "timeline.group.today")
            } else if cal.isDateInYesterday(entry.createdAt) {
                key = String(localized: "timeline.group.yesterday")
            } else {
                let f = DateFormatter()
                f.dateFormat = "MMM d"
                key = f.string(from: entry.createdAt)
            }
            if let last = buckets.last, last.0 == key {
                buckets[buckets.count - 1].1.append(entry)
            } else {
                buckets.append((key, [entry]))
            }
        }
        return buckets
    }

    private func entryRow(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let mood = entry.mood {
                    Circle()
                        .fill(theme.palette.mood[safe: mood.rawValue - 1] ?? theme.palette.accent)
                        .frame(width: 8, height: 8)
                }
                SmallCapsLabel(text: timeString(entry.createdAt), color: theme.palette.textMuted)
            }
            Text(entry.body)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
