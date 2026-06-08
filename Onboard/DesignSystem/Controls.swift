import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = Theme.Brand.primary
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.m)
            .background(
                tint.opacity(isDisabled ? 0.4 : (configuration.isPressed ? 0.8 : 1)),
                in: RoundedRectangle(cornerRadius: Theme.Radius.control)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var tint: Color = Theme.Brand.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.headline)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.m)
            .background(tint.opacity(configuration.isPressed ? 0.2 : 0.12),
                        in: RoundedRectangle(cornerRadius: Theme.Radius.control))
    }
}

struct ProgressTrack: View {
    var value: Double
    var tint: Color
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.16))
                Capsule()
                    .fill(tint)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.4), value: value)
    }
}

struct ProgressRing: View {
    var progress: Double
    var tint: Color
    var diameter: CGFloat = 64
    var lineWidth: CGFloat = 7
    var showsLabel: Bool = true

    var body: some View {
        let clamped = min(max(progress, 0), 1)
        ZStack {
            Circle()
                .stroke(tint.opacity(0.16), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [tint.opacity(0.7), tint]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            if showsLabel {
                VStack(spacing: 0) {
                    Text("\(Int(clamped * 100))")
                        .font(.system(size: diameter * 0.3, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.Ink.primary)
                    Text("%")
                        .font(.system(size: diameter * 0.16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Ink.secondary)
                }
            }
        }
        .frame(width: diameter, height: diameter)
        .animation(.easeInOut(duration: 0.5), value: clamped)
    }
}

struct StatCapsule: View {
    var value: String
    var label: String
    var tint: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(tint)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Ink.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.m)
        .background(Theme.Surface.sunken, in: RoundedRectangle(cornerRadius: Theme.Radius.control))
    }
}
