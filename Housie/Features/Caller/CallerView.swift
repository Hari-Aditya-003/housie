import AVKit
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
                .accessibilityIdentifier("callerScrollView")
                .background(HousieTheme.background.ignoresSafeArea())
            }
            .navigationTitle("Housie")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Speak numbers", isOn: $model.speechEnabled)
                        Label("Smooth English voice", systemImage: "waveform")
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
                    .accessibilityIdentifier("callerStatus")
                Spacer()
                Text("\(model.game.calledNumbers.count) / 90")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("calledCount")
            }

            calledBall

            Text(ballCaption)
                .font(.title3.weight(.semibold))
                .foregroundStyle(HousieTheme.ink)
                .contentTransition(.numericText())

            calledHistory

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
                .accessibilityIdentifier("playPauseButton")

                Button {
                    Task { await model.drawNextBall() }
                } label: {
                    Label("Next Ball", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(model.isDrawing || model.game.status == .finished)
                .accessibilityIdentifier("nextBallButton")
            }

            HStack {
                Button {
                    model.replayCurrentNumber()
                } label: {
                    Label("Repeat", systemImage: "speaker.wave.2.fill")
                }
                .disabled(model.game.currentNumber == nil)
                .accessibilityIdentifier("repeatButton")

                Spacer()

                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .accessibilityIdentifier("resetButton")
            }
            .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 8) {
                Text("Cast to TV")
                    .font(.subheadline.weight(.semibold))

                TVCastRow(
                    icon: "airplayvideo",
                    title: "Apple TV / AirPlay",
                    subtitle: "Mirror Housie to an AirPlay television"
                ) {
                    AirPlayRoutePicker()
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Cast Housie to TV with AirPlay")
                        .accessibilityIdentifier("airPlayRoutePicker")
                }

                Divider()

                TVCastRow(
                    icon: "tv",
                    title: "Android / Google TV",
                    subtitle: "Send the live board with Google Cast"
                ) {
                    GoogleCastButton()
                        .frame(width: 44, height: 44)
                }
            }
            .padding(10)
            .background(HousieTheme.magenta.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .housieCard()
        .sensoryFeedback(.impact(weight: .medium), trigger: model.game.currentNumber)
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
        .overlay {
            Circle()
                .stroke(HousieTheme.gold.opacity(model.isDrawing ? 0.75 : 0), lineWidth: 3)
                .scaleEffect(model.isDrawing ? 1.16 : 0.95)
        }
        .phaseAnimator(
            [0.0, -1.0, 0.9, -0.7, 0.55, 0.0],
            trigger: model.isDrawing
        ) { content, phase in
            content
                .offset(x: phase * 11)
                .rotationEffect(.degrees(phase * 5))
                .scaleEffect(model.isDrawing ? 0.97 : 1)
        } animation: { _ in
            .snappy(duration: 0.11, extraBounce: 0.18)
        }
        .animation(.easeOut(duration: 0.45), value: model.isDrawing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.game.currentNumber.map { "Current number \($0)" } ?? "No number called")
        .accessibilityIdentifier("currentNumberBall")
    }

    private var calledHistory: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Called Numbers")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
                if !model.game.calledNumbers.isEmpty {
                    Text("Newest first")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            if model.game.calledNumbers.isEmpty {
                Text("Called numbers will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(model.game.calledNumbers.reversed(), id: \.self) { number in
                            Text(String(number))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    number == model.game.currentNumber
                                        ? HousieTheme.saffron
                                        : HousieTheme.magenta,
                                    in: Circle()
                                )
                                .transition(.scale.combined(with: .opacity))
                                .accessibilityLabel("Called number \(number)")
                                .accessibilityIdentifier("calledNumber.\(number)")
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.72), value: model.game.calledNumbers)
        .accessibilityIdentifier("calledHistory")
    }

    private var numberBoard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("All Numbers")
                        .font(.title2.bold())
                    Text("Every number stays visible; called numbers light up")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "lightbulb.max.fill")
                    .foregroundStyle(HousieTheme.gold)
                    .font(.title2)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(minimum: 26), spacing: 4), count: 10),
                spacing: 5
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Housie number board, numbers 1 through 90")
        .accessibilityIdentifier("numberBoard")
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

private struct TVCastRow<Accessory: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(HousieTheme.magenta)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            accessory()
        }
    }
}

private struct NumberCell: View {
    let number: Int
    let isCalled: Bool
    let isCurrent: Bool

    var body: some View {
        Text(String(number))
            .font(.system(size: 15, weight: isCalled ? .black : .semibold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .foregroundStyle(isCalled ? Color.white : HousieTheme.ink.opacity(0.78))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isCalled ? HousieTheme.magenta : Color.white.opacity(0.9))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isCurrent ? HousieTheme.gold : Color.clear, lineWidth: 3)
            }
            .shadow(color: isCurrent ? HousieTheme.gold.opacity(0.5) : .clear, radius: 5)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isCalled)
            .accessibilityLabel("Number \(number), \(isCalled ? "called" : "not called")")
            .accessibilityIdentifier("numberCell.\(number)")
    }
}

private struct AirPlayRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.prioritizesVideoDevices = true
        picker.tintColor = UIColor(HousieTheme.magenta)
        picker.activeTintColor = UIColor(HousieTheme.saffron)
        return picker
    }

    func updateUIView(_ picker: AVRoutePickerView, context: Context) {
        picker.tintColor = UIColor(HousieTheme.magenta)
        picker.activeTintColor = UIColor(HousieTheme.saffron)
    }
}

#Preview {
    CallerView(model: CallerViewModel())
}
