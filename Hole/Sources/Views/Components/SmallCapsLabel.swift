import SwiftUI

struct SmallCapsLabel: View {
    let text: String
    var color: Color? = nil

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium, design: .default))
            .tracking(2.5)
            .foregroundStyle(color ?? .secondary)
    }
}
