import SwiftUI

/// Draws all directed edges between nodes as smooth lines with arrow heads.
/// Drawing once in a Canvas (instead of per-edge Shapes) keeps the canvas
/// performant even with dozens of nodes.
struct ConnectionLayer: View {
    var nodes: [FlowNode]
    var edges: [FlowEdge]
    var tint: Color = Theme.Brand.primary

    var body: some View {
        Canvas { context, _ in
            let map = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
            for edge in edges {
                guard let from = map[edge.fromID], let to = map[edge.toID] else { continue }
                draw(
                    in: &context,
                    from: from.frame(),
                    to: to.frame(),
                    completed: from.isDone && to.isDone
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func draw(
        in context: inout GraphicsContext,
        from source: CGRect,
        to destination: CGRect,
        completed: Bool
    ) {
        let start = edgePoint(of: source, towards: CGPoint(x: destination.midX, y: destination.midY))
        let end = edgePoint(of: destination, towards: CGPoint(x: source.midX, y: source.midY))

        var path = Path()
        path.move(to: start)
        let dx = end.x - start.x
        let dy = end.y - start.y
        let control1 = CGPoint(x: start.x + dx * 0.2, y: start.y + dy * 0.5)
        let control2 = CGPoint(x: start.x + dx * 0.8, y: start.y + dy * 0.5)
        path.addCurve(to: end, control1: control1, control2: control2)

        let style = StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round)
        let color = completed ? Theme.success : tint
        context.stroke(path, with: .color(color), style: style)

        drawArrowHead(in: &context, at: end, towards: control2, color: color)
    }

    /// Returns the intersection of a node's rect edge with the line towards
    /// `target` — so the connector tucks into the node border instead of
    /// crossing it.
    private func edgePoint(of rect: CGRect, towards target: CGPoint) -> CGPoint {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let dx = target.x - center.x
        let dy = target.y - center.y
        guard dx != 0 || dy != 0 else { return center }

        let halfWidth = rect.width / 2
        let halfHeight = rect.height / 2
        let scaleX = dx == 0 ? CGFloat.greatestFiniteMagnitude : halfWidth / abs(dx)
        let scaleY = dy == 0 ? CGFloat.greatestFiniteMagnitude : halfHeight / abs(dy)
        let scale = min(scaleX, scaleY)
        return CGPoint(x: center.x + dx * scale, y: center.y + dy * scale)
    }

    private func drawArrowHead(in context: inout GraphicsContext, at point: CGPoint, towards control: CGPoint, color: Color) {
        let dx = point.x - control.x
        let dy = point.y - control.y
        let angle = atan2(dy, dx)
        let length: CGFloat = 10
        let spread: CGFloat = .pi / 7

        let left = CGPoint(
            x: point.x - cos(angle - spread) * length,
            y: point.y - sin(angle - spread) * length
        )
        let right = CGPoint(
            x: point.x - cos(angle + spread) * length,
            y: point.y - sin(angle + spread) * length
        )

        var path = Path()
        path.move(to: point)
        path.addLine(to: left)
        path.addLine(to: right)
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }
}
