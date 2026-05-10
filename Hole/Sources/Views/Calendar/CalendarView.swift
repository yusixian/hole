import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.theme) private var theme
    @State private var anchorDate: Date = .now

    @Query(
        filter: #Predicate<Entry> { !$0.isPrivate },
        sort: [SortDescriptor(\Entry.createdAt, order: .reverse)]
    )
    private var entries: [Entry]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ZStack {
            PaperBackground(theme: theme)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    MonthMasthead(date: anchorDate)
                    monthHeader
                    weekdayHeader
                    monthGrid
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthString(anchorDate))
                .font(theme.fontFamily.bodyFont)
                .foregroundStyle(theme.palette.text)
            Spacer()
            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(theme.palette.accent)
    }

    private var weekdayHeader: some View {
        let symbols = Calendar.current.shortWeekdaySymbols
        return HStack(spacing: 6) {
            ForEach(symbols, id: \.self) { sym in
                Text(sym)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(theme.palette.textMuted)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(daysOfMonth(), id: \.id) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: DayCell) -> some View {
        ZStack {
            Rectangle()
                .fill(day.heatColor ?? theme.palette.surface.opacity(day.isInMonth ? 0.5 : 0))
            if day.isInMonth {
                Text("\(day.day)")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.palette.text.opacity(0.85))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private struct DayCell: Identifiable {
        let id: UUID = UUID()
        let day: Int
        let isInMonth: Bool
        let heatColor: Color?
    }

    private func daysOfMonth() -> [DayCell] {
        let cal = Calendar.current
        guard
            let monthInterval = cal.dateInterval(of: .month, for: anchorDate),
            let monthRange = cal.range(of: .day, in: .month, for: anchorDate)
        else { return [] }

        let firstWeekday = cal.component(.weekday, from: monthInterval.start)
        let leadingBlanks = firstWeekday - cal.firstWeekday
        let blanks = (leadingBlanks + 7) % 7

        var cells: [DayCell] = (0..<blanks).map { _ in
            DayCell(day: 0, isInMonth: false, heatColor: nil)
        }

        for d in monthRange {
            let date = cal.date(byAdding: .day, value: d - 1, to: monthInterval.start) ?? monthInterval.start
            let heat = heatColor(for: date)
            cells.append(DayCell(day: d, isInMonth: true, heatColor: heat))
        }
        return cells
    }

    private func heatColor(for date: Date) -> Color? {
        let cal = Calendar.current
        let entriesOfDay = entries.filter { cal.isDate($0.createdAt, inSameDayAs: date) }
        guard !entriesOfDay.isEmpty else { return nil }
        let avg = entriesOfDay.compactMap(\.mood).map(\.rawValue).reduce(0, +)
        guard avg > 0 else {
            return theme.palette.accent.opacity(0.15)
        }
        let avgIndex = max(0, min(4, (avg / entriesOfDay.count) - 1))
        return (theme.palette.mood[safe: avgIndex] ?? theme.palette.accent).opacity(0.7)
    }

    private func monthString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func shiftMonth(_ delta: Int) {
        if let next = Calendar.current.date(byAdding: .month, value: delta, to: anchorDate) {
            anchorDate = next
        }
    }
}
