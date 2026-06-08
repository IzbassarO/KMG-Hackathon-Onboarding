import SwiftUI

fileprivate struct WelcomeSlide: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let body: String
}

struct WelcomeView: View {
    var onFinish: () -> Void
    @State private var page = 0

    private let slides: [WelcomeSlide] = [
        WelcomeSlide(
            systemImage: "scribble.variable",
            title: "Map the onboarding",
            body: "Build a flowchart of stages — ID card, laptop, building pass — and the team responsible for each."
        ),
        WelcomeSlide(
            systemImage: "person.2.badge.gearshape",
            title: "Onboard real people",
            body: "Pick a template, fill in the employee's details, and start tracking them through every stage."
        ),
        WelcomeSlide(
            systemImage: "checkmark.circle.badge.checkmark",
            title: "Mark stages done",
            body: "Tap a stage when it's complete. Threadline keeps the progress, the order, and your audit story."
        )
    ]

    var body: some View {
        ZStack {
            Theme.Brand.gradient
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.l) {
                Spacer(minLength: Theme.Spacing.xxl)

                VStack(spacing: Theme.Spacing.s) {
                    ThreadlineLogo(size: 92, monochrome: true)
                    Text("Threadline")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Map the onboarding. Track every step.")
                        .font(Theme.Font.callout)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.bottom, Theme.Spacing.xl)

                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                        SlideCard(slide: slide).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(maxHeight: 360)

                Spacer()

                Button(action: advance) {
                    Label(page == slides.count - 1 ? "Get started" : "Next",
                          systemImage: page == slides.count - 1 ? "arrow.right.circle.fill" : "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle(tint: Theme.Brand.accent))
                .padding(.horizontal, Theme.Spacing.xl)

                Button("Skip", action: onFinish)
                    .font(Theme.Font.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.bottom, Theme.Spacing.xl)
            }
        }
    }

    private func advance() {
        if page < slides.count - 1 {
            withAnimation { page += 1 }
        } else {
            onFinish()
        }
    }
}

private struct SlideCard: View {
    var slide: WelcomeSlide

    var body: some View {
        VStack(spacing: Theme.Spacing.l) {
            Image(systemName: slide.systemImage)
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(.white)
                .padding(Theme.Spacing.l)
                .background(.white.opacity(0.15), in: Circle())
            Text(slide.title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
            Text(slide.body)
                .font(Theme.Font.callout)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(.top, Theme.Spacing.l)
    }
}

#Preview {
    WelcomeView(onFinish: {})
}
