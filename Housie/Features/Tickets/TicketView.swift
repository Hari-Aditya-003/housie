import SwiftUI

struct TicketView: View {
    let caller: CallerViewModel
    @State private var ticket = HousieTicket.generate()
    @State private var selectedPrize: HousiePrize = .earlyFive
    @State private var claimResult: ClaimResult?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Housie Ticket")
                            .font(.largeTitle.bold())
                        Text("Called numbers are marked automatically from the live caller board.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    TicketGrid(ticket: ticket, calledNumbers: caller.calledNumberSet)
                        .housieCard()

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Verify a claim")
                            .font(.title2.bold())

                        Picker("Prize", selection: $selectedPrize) {
                            ForEach(HousiePrize.allCases) { prize in
                                Text(prize.rawValue).tag(prize)
                            }
                        }
                        .pickerStyle(.menu)

                        Button {
                            let winner = ticket.isWinning(
                                selectedPrize,
                                calledNumbers: caller.calledNumberSet
                            )
                            claimResult = winner ? .valid : .notYet
                        } label: {
                            Label("Check \(selectedPrize.rawValue)", systemImage: "checkmark.seal.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        if let claimResult {
                            Label(claimResult.message, systemImage: claimResult.icon)
                                .font(.headline)
                                .foregroundStyle(claimResult.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(claimResult.color.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .housieCard()

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            ticket = HousieTicket.generate()
                            claimResult = nil
                        }
                    } label: {
                        Label("Generate New Ticket", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(maxWidth: 760)
                .padding(20)
            }
            .background(HousieTheme.background.ignoresSafeArea())
            .navigationTitle("Tickets")
        }
    }
}

private struct TicketGrid: View {
    let ticket: HousieTicket
    let calledNumbers: Set<Int>

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(Array(ticket.rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, number in
                        Group {
                            if let number {
                                Text(String(number))
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(calledNumbers.contains(number) ? .white : HousieTheme.ink)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(calledNumbers.contains(number) ? HousieTheme.magenta : HousieTheme.cream)
                                    }
                                    .accessibilityLabel("Number \(number), \(calledNumbers.contains(number) ? "called" : "not called")")
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(HousieTheme.saffron.opacity(0.13))
                                    .accessibilityHidden(true)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 54)
                    }
                }
            }
        }
    }
}

private enum ClaimResult {
    case valid
    case notYet

    var message: String {
        switch self {
        case .valid: "Valid claim — congratulations!"
        case .notYet: "Not yet — some required numbers are still uncalled."
        }
    }

    var icon: String {
        switch self {
        case .valid: "party.popper.fill"
        case .notYet: "clock.fill"
        }
    }

    var color: Color {
        switch self {
        case .valid: .green
        case .notYet: HousieTheme.saffron
        }
    }
}

#Preview {
    TicketView(caller: CallerViewModel())
}
