import SwiftUI

enum HousieTheme {
    static let saffron = Color(red: 0.95, green: 0.43, blue: 0.10)
    static let magenta = Color(red: 0.62, green: 0.04, blue: 0.25)
    static let ruby = Color(red: 0.78, green: 0.08, blue: 0.20)
    static let gold = Color(red: 0.98, green: 0.72, blue: 0.18)
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let royal = Color(red: 0.25, green: 0.07, blue: 0.64)
    static let midnight = Color(red: 0.08, green: 0.02, blue: 0.22)
    static let plum = Color(red: 0.32, green: 0.02, blue: 0.43)
    static let ink = Color(red: 0.10, green: 0.13, blue: 0.25)

    static let background = LinearGradient(
        colors: [
            midnight,
            Color(red: 0.14, green: 0.03, blue: 0.38),
            plum
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let titleGradient = LinearGradient(
        colors: [Color.yellow, gold, saffron, Color(red: 1.0, green: 0.22, blue: 0.48)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct HousieBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HousieTheme.background

                Canvas { context, size in
                    let center = CGPoint(x: size.width * 0.5, y: size.height * 0.62)
                    let radius = max(size.width, size.height) * 1.4

                    for ray in 0..<18 {
                        let angle = (Double(ray) / 18 * Double.pi * 2) - Double.pi / 2
                        let spread = Double.pi / 34
                        var path = Path()
                        path.move(to: center)
                        path.addLine(
                            to: CGPoint(
                                x: center.x + CGFloat(cos(angle - spread)) * radius,
                                y: center.y + CGFloat(sin(angle - spread)) * radius
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: center.x + CGFloat(cos(angle + spread)) * radius,
                                y: center.y + CGFloat(sin(angle + spread)) * radius
                            )
                        )
                        path.closeSubpath()
                        context.fill(
                            path,
                            with: .color(Color.purple.opacity(ray.isMultiple(of: 2) ? 0.16 : 0.08))
                        )
                    }
                }

                RadialGradient(
                    colors: [HousieTheme.magenta.opacity(0.36), .clear],
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.72
                )

                RadialGradient(
                    colors: [HousieTheme.saffron.opacity(0.18), .clear],
                    center: .topLeading,
                    startRadius: 4,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.62
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Housie Ka King themed background")
        .accessibilityIdentifier("housieBackdrop")
    }
}

struct HousieCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(HousieTheme.gold.opacity(0.48), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.26), radius: 20, y: 10)
    }
}

struct HousieCopyright: View {
    var body: some View {
        Text("© Hari")
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color.white.opacity(0.62))
            .accessibilityIdentifier("copyrightHari")
    }
}

extension View {
    func housieCard() -> some View { modifier(HousieCard()) }
}
