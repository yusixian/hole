import SwiftUI

struct PaperBackground: View {
    let theme: Theme

    var body: some View {
        ZStack {
            theme.palette.bg
            switch theme.texture {
            case .none:
                EmptyView()
            case .washi:
                noiseLayer(opacity: 0.06, blendMode: .multiply)
                fiberLayer(color: theme.palette.textMuted, opacity: 0.05)
            case .newsprint:
                noiseLayer(opacity: 0.08, blendMode: .multiply)
            case .linen:
                linenLayer(opacity: 0.07)
            case .nightInk:
                noiseLayer(opacity: 0.05, blendMode: .screen)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func noiseLayer(opacity: Double, blendMode: BlendMode) -> some View {
        Canvas { context, size in
            for _ in 0..<800 {
                let x = Double.random(in: 0..<size.width)
                let y = Double.random(in: 0..<size.height)
                let r = Double.random(in: 0.4...1.4)
                let rect = CGRect(x: x, y: y, width: r, height: r)
                let alpha = Double.random(in: 0.2...0.7)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(theme.palette.text.opacity(alpha))
                )
            }
        }
        .opacity(opacity)
        .blendMode(blendMode)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func fiberLayer(color: Color, opacity: Double) -> some View {
        Canvas { context, size in
            for _ in 0..<60 {
                let x1 = Double.random(in: 0..<size.width)
                let y1 = Double.random(in: 0..<size.height)
                let x2 = x1 + Double.random(in: -40...40)
                let y2 = y1 + Double.random(in: -1...1)
                var path = Path()
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))
                context.stroke(path, with: .color(color), lineWidth: 0.4)
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func linenLayer(opacity: Double) -> some View {
        Canvas { context, size in
            let step: CGFloat = 3
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(theme.palette.textMuted.opacity(0.4)), lineWidth: 0.3)
                y += step
            }
            var x: CGFloat = 0
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(theme.palette.textMuted.opacity(0.25)), lineWidth: 0.3)
                x += step
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
    }
}
