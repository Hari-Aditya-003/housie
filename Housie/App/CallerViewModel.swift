import AVFoundation
import Observation

@MainActor
@Observable
final class CallerViewModel {
    private(set) var game = HousieGame()
    private(set) var isDrawing = false
    var speechEnabled = true
    var callInterval = 6.0

    @ObservationIgnored private let speaker = AVSpeechSynthesizer()
    @ObservationIgnored private let castManager: GoogleCastManager
    @ObservationIgnored private var automaticTask: Task<Void, Never>?
    @ObservationIgnored private lazy var englishVoice = Self.preferredEnglishVoice()

    var calledNumberSet: Set<Int> { Set(game.calledNumbers) }

    init(castManager: GoogleCastManager? = nil) {
        let manager = castManager ?? .shared
        self.castManager = manager
        manager.publish(game: game)
    }

    func togglePlayPause() {
        if game.status == .running {
            pause()
        } else {
            game.play()
            startAutomaticCalling()
            publishCastState()
        }
    }

    func pause() {
        game.pause()
        automaticTask?.cancel()
        automaticTask = nil
        publishCastState()
    }

    func drawNextBall() async {
        guard !isDrawing, !game.remainingNumbers.isEmpty else { return }

        isDrawing = true
        try? await Task.sleep(for: .milliseconds(700))
        guard !Task.isCancelled else {
            isDrawing = false
            return
        }

        if let number = game.drawNext() {
            announce(number)
            publishCastState()
        }
        isDrawing = false
    }

    func reset() {
        automaticTask?.cancel()
        automaticTask = nil
        speaker.stopSpeaking(at: .immediate)
        isDrawing = false
        game.reset()
        publishCastState()
    }

    func replayCurrentNumber() {
        guard let number = game.currentNumber else { return }
        announce(number)
    }

    private func startAutomaticCalling() {
        automaticTask?.cancel()
        automaticTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, self.game.status == .running else { return }
                try? await Task.sleep(for: .seconds(self.callInterval))
                guard !Task.isCancelled, self.game.status == .running else { return }
                await self.drawNextBall()
            }
        }
    }

    private func announce(_ number: Int) {
        guard speechEnabled else { return }
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .spokenAudio,
            options: [.duckOthers]
        )
        speaker.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: String(number))
        utterance.voice = englishVoice
        utterance.rate = 0.46
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.06
        utterance.postUtteranceDelay = 0.08
        speaker.speak(utterance)
    }

    private func publishCastState() {
        castManager.publish(game: game)
    }

    private static func preferredEnglishVoice() -> AVSpeechSynthesisVoice? {
        let localePriority = ["en-IN", "en-GB", "en-US"]
        let englishVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en")
        }

        return englishVoices.sorted { first, second in
            if first.quality.rawValue != second.quality.rawValue {
                return first.quality.rawValue > second.quality.rawValue
            }

            let firstPriority = localePriority.firstIndex(of: first.language) ?? localePriority.count
            let secondPriority = localePriority.firstIndex(of: second.language) ?? localePriority.count
            return firstPriority < secondPriority
        }.first ?? AVSpeechSynthesisVoice(language: "en-IN")
    }
}
