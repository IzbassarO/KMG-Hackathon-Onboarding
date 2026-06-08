import SwiftUI

struct Card<Content: View>: View {
    var padding: CGFloat
    var content: Content

    init(padding: CGFloat = Theme.Spacing.l, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content.threadCard(padding: padding)
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String?
    var systemImage: String?

    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.s) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(Theme.Brand.primary)
            }
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(title)
                    .font(Theme.Font.section)
                    .foregroundStyle(Theme.Ink.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Font.callout)
                        .foregroundStyle(Theme.Ink.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct Pill: View {
    var text: String
    var systemImage: String?
    var tint: Color

    init(_ text: String, systemImage: String? = nil, tint: Color = Theme.Ink.secondary) {
        self.text = text
        self.systemImage = systemImage
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2)
            }
            Text(text)
                .font(Theme.Font.caption.weight(.medium))
        }
        .padding(.horizontal, Theme.Spacing.s)
        .padding(.vertical, Theme.Spacing.xs)
        .background(tint.opacity(0.12), in: Capsule())
        .foregroundStyle(tint)
    }
}

struct Avatar: View {
    var name: String
    var diameter: CGFloat = 44

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }

    private var tint: Color {
        let palette: [Color] = [
            Theme.Brand.primary, Theme.info,
            Color(rgb: 0x8E5BD8), Color(rgb: 0xD8635B), Color(rgb: 0x2BA39B)
        ]
        let index = abs(name.hashValue) % palette.count
        return palette[index]
    }

    var body: some View {
        Text(initials.isEmpty ? "•" : initials)
            .font(.system(size: diameter * 0.4, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(
                LinearGradient(
                    colors: [tint, tint.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
    }
}
