import SwiftUI

/// Soft dotted grid backdrop for the flowchart canvas — gives the builder a
/// "Sketch" feel without overwhelming the rest of the UI.
struct CanvasGrid: View {
    var size: CGSize = CanvasMetrics.canvasSize
    var spacing: CGFloat = CanvasMetrics.gridSpacing

    var body: some View {
        Canvas { context, canvasSize in
            let dot: CGFloat = 1.6
            var path = Path()
            var x = spacing
            while x < canvasSize.width {
                var y = spacing
                while y < canvasSize.height {
                    path.addEllipse(in: CGRect(x: x - dot/2, y: y - dot/2, width: dot, height: dot))
                    y += spacing
                }
                x += spacing
            }
            context.fill(path, with: .color(Theme.Surface.canvasGrid))
        }
        .frame(width: size.width, height: size.height)
    }
}
