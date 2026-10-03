import SwiftUI

struct CallerView: View {
    @Bindable var model: CallerViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    if proxy.size.width >= 760 {
                        HStack(alignment: .top, spacing: 22) {
                            callerPanel
                                .frame(width: min(350, proxy.size.width * 0.34))
                            numberBoard
                        }
                        .padding(24)
                    } else {
                        VStack(spacing: 18) {
                            callerPanel
                            numberBoard
                        }
                        .padding(16)
                    }
                }
                .background(HousieTheme.background.ignoresSafeArea())
            }
            .navigationTitle("Housie")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Speak numbers", isOn: $model.speechEnabled)
                        Picker("Voice", selection: $model.announcementLanguage) {
                            ForEach(AnnouncementLanguage.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        Section("Auto-call speed") {
                            Picker("Interval", selection: $model.callInterval) {
                                Text("4 seconds").tag(4.0)
                                Text("6 seconds").tag(6.0)
                                Text("8 seconds").tag(8.0)
                                Text("10 seconds").tag(10.0)
                            }
                        }
                    } label: {
                        Label("Caller settings", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .confirmationDialog(
                "Start a fresh game?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset all numbers", role: .destructive) { model.reset() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears every called number and returns all 90 balls.")
            }
        }
    }

    private var callerPanel: some View {
        VStack(spacing: 18) {
            HStack {
                Label(statusTitle, systemImage: statusIcon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusColor)
                Spacer()
                Text("\(model.game.calledNumbers.count) / 90")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            calledBall

            Text(ballCaption)
                .font(.title3.weight(.semibold))
                .foregroundStyle(HousieTheme.ink)
                .contentTransition(.numericText())

            ProgressView(value: Double(model.game.calledNumbers.count), total: 90)
                .tint(HousieTheme.saffron)

            HStack(spacing: 12) {
                Button {
                    model.togglePlayPause()
                } label: {
                    Label(
                        model.game.status == .running ? "Pause" : "Play",
                        systemImage: model.game.status == .running ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(model.game.status == .finished)

                Button {
                    Task { await model.drawNextBall() }
                } label: {
                    Label("Next Ball", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(model.isDrawing || model.game.status == .finished)
            }

            HStack {
                Button {
                    model.replayCurrentNumber()
                } label: {
                    Label("Repeat", systemImage: "speaker.wave.2.fill")
                }
                .disabled(model.game.currentNumber == nil)

                Spacer()

                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }
            .font(.subheadline.weight(.semibold))
        }
        .housieCard()
    }

    private var calledBall: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, HousieTheme.cream, HousieTheme.gold.opacity(0.55)],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: 115
                    )
                )
            Circle()
                .stroke(HousieTheme.gold, lineWidth: 8)
                .padding(7)
            Text(model.game.currentNumber.map(String.init) ?? "?")
                .font(.system(size: 78, weight: .black, design: .rounded))
                .minimumScaleFactor(0.6)
                .foregroundStyle(HousieTheme.magenta)
                .contentTransition(.numericText())
        }
        .frame(width: 205, height: 205)
        .shadow(color: HousieTheme.saffron.opacity(0.24), radius: 18, y: 10)
        .rotationEffect(.degrees(model.isDrawing ? 7 : 0))
        .offset(x: model.isDrawing ? 9 : 0)
        .scaleEffect(model.isDrawing ? 0.96 : 1)
        .animation(
            model.isDrawing
                ? .easeInOut(duration: 0.08).repeatCount(8, autoreverses: true)
                : .spring(response: 0.35, dampingFraction: 0.65),
            value: model.isDrawing
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.game.currentNumber.map { "Current number \($0)" } ?? "No number called")
    }

    private var numberBoard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Caller Board")
                        .font(.title2.bold())
                    Text("Called numbers stay lit until the game ends")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "lightbulb.max.fill")
                    .foregroundStyle(HousieTheme.gold)
                    .font(.title2)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 10),
                spacing: 7
            ) {
                ForEach(1...90, id: \.self) { number in
                    NumberCell(
                        number: number,
                        isCalled: model.calledNumberSet.contains(number),
                        isCurrent: model.game.currentNumber == number
                    )
                }
            }
        }
        .housieCard()
    }

    private var statusTitle: String {
        switch model.game.status {
        case .ready: "Ready to begin"
        case .running: "Calling automatically"
        case .paused: "Game paused"
        case .finished: "All numbers called"
        }
    }

    private var statusIcon: String {
        switch model.game.status {
        case .ready: "flag.checkered"
        case .running: "waveform"
        case .paused: "pause.circle.fill"
        case .finished: "trophy.fill"
        }
    }

    private var statusColor: Color {
        model.game.status == .finished ? HousieTheme.magenta : HousieTheme.saffron
    }

    private var ballCaption: String {
        if model.isDrawing { return "Shaking the ball…" }
        if let current = model.game.currentNumber { return "Number \(current)" }
        return "Tap Play or Next Ball"
    }
}

private struct NumberCell: View {
    let number: Int
    let isCalled: Bool
    let isCurrent: Bool

    var body: some View {
        Text(String(number))
            .font(.system(.callout, design: .rounded, weight: isCalled ? .bold : .medium))
            .monospacedDigit()
            .foregroundStyle(isCalled ? Color.white : HousieTheme.ink.opacity(0.58))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isCalled ? HousieTheme.magenta : Color.white.opacity(0.72))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isCurrent ? HousieTheme.gold : Color.clear, lineWidth: 3)
            }
            .shadow(color: isCurrent ? HousieTheme.gold.opacity(0.5) : .clear, radius: 5)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isCalled)
            .accessibilityLabel("Number \(number), \(isCalled ? "called" : "not called")")
    }
}

#Preview {
    CallerView(model: CallerViewModel())
}
