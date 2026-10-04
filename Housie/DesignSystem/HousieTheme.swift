import SwiftUI

enum HousieTheme {
    static let saffron = Color(red: 0.95, green: 0.43, blue: 0.10)
    static let magenta = Color(red: 0.62, green: 0.04, blue: 0.25)
    static let ruby = Color(red: 0.78, green: 0.08, blue: 0.20)
    static let gold = Color(red: 0.98, green: 0.72, blue: 0.18)
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let royal = Color(red: 0.20, green: 0.18, blue: 0.52)
    static let teal = Color(red: 0.08, green: 0.48, blue: 0.50)
    static let ink = Color(red: 0.10, green: 0.13, blue: 0.25)

    static let background = LinearGradient(
        colors: [
            Color(red: 0.91, green: 0.96, blue: 1.0),
            Color(red: 0.94, green: 0.98, blue: 0.96),
            Color(red: 1.0, green: 0.94, blue: 0.91)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct HousieCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            }
            .shadow(color: HousieTheme.royal.opacity(0.10), radius: 18, y: 9)
    }
}

struct HousieCopyright: View {
    var body: some View {
        Text("© Hari")
            .font(.caption2.weight(.medium))
            .foregroundStyle(HousieTheme.ink.opacity(0.48))
            .accessibilityIdentifier("copyrightHari")
    }
}

extension View {
    func housieCard() -> some View { modifier(HousieCard()) }
}
