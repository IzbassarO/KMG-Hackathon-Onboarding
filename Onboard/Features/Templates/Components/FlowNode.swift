import Foundation
import CoreGraphics

/// Lightweight view-model snapshot for one ticket node on the canvas. Decouples
/// the canvas renderer from the underlying SwiftData @Model so the same canvas
/// works for both Template and Onboarding flowcharts.
struct FlowNode: Identifiable, Hashable {
    var id: UUID
    var title: String
    var owner: String
    var notes: String
    var priority: TicketPriority
    /// Present only in tracker (onboarding) mode; nil while editing a template.
    var status: TicketStatus?
    var position: CGPoint

    static let nodeSize = CGSize(width: 230, height: 104)

    var topLeft: CGPoint {
        CGPoint(x: position.x - Self.nodeSize.width / 2,
                y: position.y - Self.nodeSize.height / 2)
    }

    func frame() -> CGRect {
        CGRect(origin: topLeft, size: Self.nodeSize)
    }

    var isDone: Bool { status == .done }
}

struct FlowEdge: Identifiable, Hashable {
    var id: UUID
    var fromID: UUID
    var toID: UUID
}

enum CanvasMetrics {
    static let canvasSize = CGSize(width: 1600, height: 2400)
    static let gridSpacing: CGFloat = 32
    static let coordinateSpace = "threadline.flowCanvas"
}
