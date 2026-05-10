import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context

    @State private var streak: Int = 0
    @State private var monthCounts: [Int] = Array(repeating: 0, count: 5)
    @State private var entryCount: Int = 0
    @State private var usageCounts: [String: Int] = [:]

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    streakCard
                    moodCurveCard
                    aiUsageCard
                    Spacer(minLength: 30)
                }
                .padding(20)
            }
        }
        .navigationTitle(Text("stats.nav"))
        .navigationBarTitleDisplayMode(.inline)
        .task { reload() }
    }

    private var streakCard: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                SmallCapsLabel(text: String(localized: "stats.streak"), color: theme.palette.textMuted)
                Text("\(streak)")
                    .font(.system(size: 56, weight: .light, design: .serif))
                    .foregroundStyle(theme.palette.accent)
                Text("stats.streak.unit")
                    .font(theme.fontFamily.bodyFont)
                    .foregroundStyle(theme.palette.text)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                SmallCapsLabel(text: String(localized: "stats.thisMonth"), color: theme.palette.textMuted)
                Text("\(entryCount)")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(theme.palette.text)
                Text("stats.entries.unit")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.palette.textMuted)
            }
        }
        .padding(18)
        .background(theme.palette.surface)
    }

    private var moodCurveCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SmallCapsLabel(text: String(localized: "stats.monthMood"), color: theme.palette.textMuted)
            MoodBarChart(counts: monthCounts)
            HStack(spacing: 4) {
                ForEach(Mood.allCases) { mood in
                    Text(mood.emoji)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(18)
        .background(theme.palette.surface)
    }

    private var aiUsageCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SmallCapsLabel(text: String(localized: "stats.aiUsage"), color: theme.palette.textMuted)
            usageRow(key: "aiEcho", labelKey: "stats.usage.echo")
            usageRow(key: "aiTag", labelKey: "stats.usage.autoTag")
            usageRow(key: "aiSummary", labelKey: "stats.usage.summary")
            usageRow(key: "aiChat", labelKey: "stats.usage.chat")
        }
        .padding(18)
        .background(theme.palette.surface)
    }

    private func usageRow(key: String, labelKey: LocalizedStringKey) -> some View {
        HStack {
            Text(labelKey)
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
            Spacer()
            Text("\(usageCounts[key, default: 0])")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.palette.accent)
        }
    }

    private func reload() {
        let stats = StatsService(context: context)
        streak = (try? stats.currentStreakDays()) ?? 0
        monthCounts = (try? stats.monthMoodCounts()) ?? Array(repeating: 0, count: 5)
        entryCount = (try? stats.entryCountThisMonth()) ?? 0
        usageCounts = (try? stats.aiUsageCounts()) ?? [:]
    }
}
