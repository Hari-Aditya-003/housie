import SwiftUI

enum HousieTheme {
    static let saffron = Color(red: 0.95, green: 0.43, blue: 0.10)
    static let magenta = Color(red: 0.62, green: 0.04, blue: 0.25)
    static let ruby = Color(red: 0.78, green: 0.08, blue: 0.20)
    static let gold = Color(red: 0.98, green: 0.72, blue: 0.18)
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let ink = Color(red: 0.20, green: 0.10, blue: 0.12)

    static let background = LinearGradient(
        colors: [cream, Color.white, Color(red: 1.0, green: 0.91, blue: 0.78)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct HousieCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1)
            }
            .shadow(color: HousieTheme.magenta.opacity(0.09), radius: 16, y: 8)
    }
}

extension View {
    func housieCard() -> some View { modifier(HousieCard()) }
}
