import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
            Text("Hole")
                .font(.largeTitle.bold())
            Text("树洞 · Coming soon")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
