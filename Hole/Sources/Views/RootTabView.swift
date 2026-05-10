import SwiftUI

enum RootTab: Hashable {
    case today, timeline, calendar, settings
}

struct RootTabView: View {
    @State private var selection: RootTab = .today

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tabItem {
                    Label("tab.today", systemImage: "sun.max")
                }
                .tag(RootTab.today)

            TimelineView()
                .tabItem {
                    Label("tab.timeline", systemImage: "list.bullet.indent")
                }
                .tag(RootTab.timeline)

            CalendarView()
                .tabItem {
                    Label("tab.calendar", systemImage: "calendar")
                }
                .tag(RootTab.calendar)

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
                .tag(RootTab.settings)
        }
    }
}
