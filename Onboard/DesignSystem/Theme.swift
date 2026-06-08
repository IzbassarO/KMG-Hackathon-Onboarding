import SwiftUI

/// Central design tokens for Threadline. Asset names below let designers
/// override the palette by adding color sets to Assets.xcassets — the code
/// falls back to the hex values otherwise so the UI looks finished out of the
/// box in both light and dark mode.
enum Theme {

    // MARK: Brand

    enum Brand {
        /// Threadline primary — petrol teal (a nod to KMG + petroleum heritage).
        static let primary = Color(asset: "ThreadPrimary", light: 0x0E6E66, dark: 0x2DB7A6)
        /// Deeper petrol used for gradients, hero strips, builder backdrops.
        static let primaryDeep = Color(asset: "ThreadPrimaryDeep", light: 0x0A4D47, dark: 0x14857A)
        /// Amber signal for primary actions, completion markers, and the brand dot.
        static let accent = Color(asset: "ThreadAccent", light: 0xE07B2C, dark: 0xFFAE57)

        static var gradient: LinearGradient {
            LinearGradient(
                colors: [primaryDeep, primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: Surfaces

    enum Surface {
        static let base = Color(asset: "BackgroundBase", light: 0xF4F7F6, dark: 0x0D1413)
        static let elevated = Color(asset: "BackgroundElevated", light: 0xFFFFFF, dark: 0x18211F)
        static let sunken = Color(asset: "BackgroundSunken", light: 0xEAF0EE, dark: 0x0A0F0E)
        static let separator = Color(asset: "ThreadSeparator", light: 0xDDE5E3, dark: 0x273230)
        /// Soft grid backdrop for the flowchart builder canvas.
        static let canvasGrid = Color(asset: "CanvasGrid", light: 0xE3EBE9, dark: 0x1A2624)
    }

    // MARK: Text

    enum Ink {
        static let primary = Color(asset: "TextPrimary", light: 0x0E1413, dark: 0xF1F5F4)
        static let secondary = Color(asset: "TextSecondary", light: 0x5A6B68, dark: 0x9DB0AC)
    }

    // MARK: Semantic

    static let info = Color(asset: "ThreadInfo", light: 0x2563C9, dark: 0x6AA1FF)
    static let success = Color(asset: "ThreadSuccess", light: 0x1E9E66, dark: 0x3CCB88)
    static let warning = Color(asset: "ThreadWarning", light: 0xCE8211, dark: 0xF3B44C)
    static let danger = Color(asset: "ThreadDanger", light: 0xCE3A43, dark: 0xFF6B72)

    static func tint(for status: TicketStatus) -> Color {
        switch status {
        case .open: return Ink.secondary
        case .inProgress: return info
        case .done: return success
        case .blocked: return danger
        }
    }

    static func tint(for priority: TicketPriority) -> Color {
        switch priority {
        case .low: return Ink.secondary
        case .medium: return info
        case .high: return warning
        }
    }

    // MARK: Metrics

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let chip: CGFloat = 8
        static let control: CGFloat = 12
        static let card: CGFloat = 20
        static let hero: CGFloat = 28
        static let node: CGFloat = 14
    }

    // MARK: Typography

    enum Font {
        static let hero = SwiftUI.Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = SwiftUI.Font.system(.title2, design: .rounded).weight(.bold)
        static let section = SwiftUI.Font.system(.title3, design: .rounded).weight(.semibold)
        static let headline = SwiftUI.Font.system(.headline, design: .rounded)
        static let body = SwiftUI.Font.system(.body)
        static let callout = SwiftUI.Font.system(.callout)
        static let caption = SwiftUI.Font.system(.caption)
        static let mono = SwiftUI.Font.system(.caption2, design: .monospaced)
    }

    static let cardShadow = Color.black.opacity(0.06)
}

extension View {
    /// Standard elevated card container used across the app.
    func threadCard(padding: CGFloat = Theme.Spacing.l) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Surface.elevated, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Theme.Surface.separator, lineWidth: 0.5)
            )
            .shadow(color: Theme.cardShadow, radius: 12, x: 0, y: 6)
    }
}
