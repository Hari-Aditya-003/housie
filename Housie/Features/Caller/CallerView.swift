import AVKit
import SwiftUI

struct CallerView: View {
    @Bindable var model: CallerViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    adaptiveContent(in: proxy.size)
                        .frame(maxWidth: 1_180)
                        .frame(maxWidth: .infinity)
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

    @ViewBuilder
    private func adaptiveContent(in size: CGSize) -> some View {
        let usesSplitLayout = size.width >= 700
        let hasShortHeight = size.height < 560
        let outerPadding: CGFloat = usesSplitLayout ? 22 : 14
        let panelWidth = min(340, size.width * 0.36)
        let ballDiameter: CGFloat = hasShortHeight ? 132 : (usesSplitLayout ? 174 : 168)

        VStack(spacing: 12) {
            if usesSplitLayout {
                HStack(alignment: .top, spacing: 18) {
                    callerPanel(ballDiameter: ballDiameter, compact: hasShortHeight)
                        .frame(width: panelWidth)
                    numberBoard
                }
            } else {
                VStack(spacing: 16) {
                    callerPanel(ballDiameter: ballDiameter, compact: false)
                    numberBoard
                }
            }

            compactCastControls
            HousieCopyright()
        }
        .padding(.horizontal, outerPadding)
        .padding(.top, outerPadding)
        .padding(.bottom, 10)
    }

    private func callerPanel(ballDiameter: CGFloat, compact: Bool) -> some View {
        VStack(spacing: compact ? 12 : 16) {
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

            calledBall(diameter: ballDiameter)

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

        }
        .housieCard()
        .sensoryFeedback(.impact(weight: .medium), trigger: model.game.currentNumber)
    }

    private func calledBall(diameter: CGFloat) -> some View {
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
        .frame(width: diameter, height: diameter)
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

    private var compactCastControls: some View {
        HStack(spacing: 8) {
            Label("TV", systemImage: "tv.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(HousieTheme.royal)

            Divider()
                .frame(height: 22)

            AirPlayRoutePicker()
                .frame(width: 30, height: 30)
                .accessibilityLabel("Cast Housie to TV with AirPlay")
                .accessibilityIdentifier("airPlayRoutePicker")

            GoogleCastButton()
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: HousieTheme.royal.opacity(0.10), radius: 8, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cast Housie to a television")
        .accessibilityIdentifier("compactCastControls")
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

private struct NumberCell: View {
    let number: Int
    let isCalled: Bool
    let isCurrent: Bool

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)

            ZStack {
                Circle()
                    .fill(cellColor)

                Circle()
                    .strokeBorder(
                        isCurrent ? HousieTheme.gold : Color.white.opacity(isCalled ? 0.42 : 0.95),
                        lineWidth: isCurrent ? max(2.5, diameter * 0.08) : 1
                    )

                Text(String(number))
                    .font(
                        .system(
                            size: min(30, max(12, diameter * 0.42)),
                            weight: isCalled ? .black : .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(isCalled ? Color.white : HousieTheme.ink.opacity(0.82))
                    .padding(diameter * 0.14)
            }
            .frame(width: diameter, height: diameter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(
            color: isCurrent ? HousieTheme.gold.opacity(0.55) : HousieTheme.royal.opacity(isCalled ? 0.12 : 0.04),
            radius: isCurrent ? 6 : 2,
            y: isCurrent ? 2 : 1
        )
        .scaleEffect(isCurrent ? 1.06 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: isCalled)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
        .accessibilityLabel("Number \(number), \(isCalled ? "called" : "not called")")
        .accessibilityIdentifier("numberCell.\(number)")
    }

    private var cellColor: Color {
        if isCurrent { return HousieTheme.saffron }
        if isCalled { return HousieTheme.royal }
        return Color.white.opacity(0.88)
    }
}

private struct AirPlayRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.prioritizesVideoDevices = true
        picker.tintColor = UIColor(HousieTheme.royal)
        picker.activeTintColor = UIColor(HousieTheme.saffron)
        return picker
    }

    func updateUIView(_ picker: AVRoutePickerView, context: Context) {
        picker.tintColor = UIColor(HousieTheme.royal)
        picker.activeTintColor = UIColor(HousieTheme.saffron)
    }
}

#Preview {
    CallerView(model: CallerViewModel())
}
