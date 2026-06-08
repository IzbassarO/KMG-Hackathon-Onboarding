import SwiftUI

/// Threadline brand mark — a single thread that loops through three nodes
/// (rounded squares) and ends with an amber dot. Represents the user's
/// onboarding flow as a thread you weave from stage to stage.
struct ThreadlineLogo: View {
    var size: CGFloat = 56
    var monochrome: Bool = false

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let nodeSize = w * 0.22
            let radius = nodeSize * 0.28

            let nodes: [CGPoint] = [
                CGPoint(x: w * 0.20, y: h * 0.30),
                CGPoint(x: w * 0.50, y: h * 0.65),
                CGPoint(x: w * 0.80, y: h * 0.30)
            ]

            // Thread (cubic bezier connecting node centers)
            var thread = Path()
            thread.move(to: nodes[0])
            thread.addCurve(
                to: nodes[1],
                control1: CGPoint(x: w * 0.30, y: h * 0.70),
                control2: CGPoint(x: w * 0.40, y: h * 0.30)
            )
            thread.addCurve(
                to: nodes[2],
                control1: CGPoint(x: w * 0.60, y: h * 0.90),
                control2: CGPoint(x: w * 0.70, y: h * 0.10)
            )
            context.stroke(
                thread,
                with: monochrome
                    ? .color(.white)
                    : .linearGradient(
                        Gradient(colors: [Theme.Brand.primaryDeep, Theme.Brand.primary]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: w, y: h)
                    ),
                style: StrokeStyle(lineWidth: w * 0.06, lineCap: .round)
            )

            // Nodes
            for (index, point) in nodes.enumerated() {
                let rect = CGRect(
                    x: point.x - nodeSize / 2,
                    y: point.y - nodeSize / 2,
                    width: nodeSize,
                    height: nodeSize
                )
                let path = Path(roundedRect: rect, cornerRadius: radius)
                let isLast = index == nodes.count - 1
                let fill: Color = monochrome
                    ? .white
                    : (isLast ? Theme.Brand.accent : Theme.Brand.primaryDeep)
                context.fill(path, with: .color(fill))
            }
        }
        .frame(width: size, height: size)
    }
}

struct ThreadlineWordmark: View {
    var size: CGFloat = 28

    var body: some View {
        HStack(spacing: Theme.Spacing.s) {
            ThreadlineLogo(size: size * 1.4)
            Text("Threadline")
                .font(.system(size: size, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Ink.primary)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        ThreadlineLogo(size: 120)
        ThreadlineWordmark()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Surface.base)
}
