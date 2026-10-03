import SwiftUI

struct HowToPlayView: View {
    private let steps: [(String, String, String)] = [
        ("1", "Get a ticket", "Each player uses a 3 × 9 ticket containing 15 numbers from 1 to 90."),
        ("2", "Start the caller", "Tap Play for automatic calling, or use Next Ball to call numbers manually."),
        ("3", "Mark numbers", "Players cross off each number when it is announced and lit on the board."),
        ("4", "Claim a prize", "Call out immediately for Early Five, Top Line, Middle Line, Bottom Line, or Full House."),
        ("5", "Verify", "Open Tickets, choose the claimed prize, and check it against all numbers called so far.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 10) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(HousieTheme.saffron)
                        Text("Gather. Call. Celebrate.")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text("A simple digital caller for family gatherings, festivals, and community celebrations.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 8)

                    ForEach(steps, id: \.0) { step in
                        HStack(alignment: .top, spacing: 14) {
                            Text(step.0)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(HousieTheme.magenta, in: Circle())
                            VStack(alignment: .leading, spacing: 5) {
                                Text(step.1)
                                    .font(.headline)
                                Text(step.2)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .housieCard()
                    }

                    Text("Tip: connect your iPhone or iPad to a speaker so everyone can hear the called number clearly.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(HousieTheme.magenta)
                        .padding()
                }
                .frame(maxWidth: 700)
                .padding(20)
            }
            .background(HousieTheme.background.ignoresSafeArea())
            .navigationTitle("How to Play")
        }
    }
}

#Preview {
    HowToPlayView()
}
