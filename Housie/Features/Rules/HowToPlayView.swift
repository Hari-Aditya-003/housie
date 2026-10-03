import SwiftUI

struct HowToPlayView: View {
    private let steps: [(String, String, String)] = [
        ("play.fill", "Start", "Tap Play for automatic calls, or Next Ball to call one number."),
        ("speaker.wave.2.fill", "Listen", "The app speaks each number in a smooth English voice."),
        ("square.grid.3x3.fill", "Follow", "Called numbers light up and remain visible on the 1–90 board."),
        ("airplayvideo", "Share", "Use Cast to TV for AirPlay, or pause and reset whenever needed.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("How It Works")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(steps, id: \.0) { step in
                        HStack(spacing: 12) {
                            Image(systemName: step.0)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(HousieTheme.magenta, in: RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 5) {
                                Text(step.1)
                                    .font(.headline)
                                Text(step.2)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .frame(maxWidth: 540)
                .padding(16)
            }
            .background(HousieTheme.background.ignoresSafeArea())
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HowToPlayView()
}
