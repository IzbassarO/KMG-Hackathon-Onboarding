import SwiftUI

/// Visual ticket rectangle on the canvas. Used for both the template editor
/// (no status) and the onboarding tracker (with status).
struct FlowNodeView: View {
    var node: FlowNode
    var isConnectSource: Bool
    var isConnectTarget: Bool

    private var accent: Color {
        if let status = node.status { return Theme.tint(for: status) }
        return Theme.Brand.primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.xs) {
                if let status = node.status {
                    Image(systemName: status.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(accent)
                }
                Text(node.title.isEmpty ? "Untitled ticket" : node.title)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Theme.Ink.primary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                PriorityDot(priority: node.priority)
            }

            if !node.owner.isEmpty {
                Pill(node.owner, systemImage: "person.fill", tint: Theme.Brand.primary)
            }

            if let status = node.status {
                Text(status.displayName)
                    .font(Theme.Font.caption.weight(.semibold))
                    .foregroundStyle(accent)
            } else if !node.notes.isEmpty {
                Text(node.notes)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Ink.secondary)
                    .lineLimit(2)
            }
        }
        .padding(Theme.Spacing.m)
        .frame(width: FlowNode.nodeSize.width, height: FlowNode.nodeSize.height, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.node)
                .fill(node.isDone ? Theme.success.opacity(0.12) : Theme.Surface.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.node)
                .strokeBorder(strokeColor, lineWidth: strokeWidth)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accent)
                .frame(width: 4)
                .padding(.vertical, Theme.Spacing.s)
        }
        .shadow(color: Theme.cardShadow, radius: 6, x: 0, y: 3)
    }

    private var strokeColor: Color {
        if isConnectSource { return Theme.Brand.accent }
        if isConnectTarget { return Theme.info }
        if node.isDone { return Theme.success.opacity(0.4) }
        return Theme.Surface.separator
    }

    private var strokeWidth: CGFloat {
        (isConnectSource || isConnectTarget) ? 2 : 0.6
    }
}

struct PriorityDot: View {
    var priority: TicketPriority

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: priority.systemImage)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(Theme.tint(for: priority))
        .padding(4)
        .background(Theme.tint(for: priority).opacity(0.14), in: Circle())
    }
}
