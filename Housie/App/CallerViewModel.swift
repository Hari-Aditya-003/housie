import AVFoundation
import Observation

enum AnnouncementLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case telugu = "తెలుగు"

    var id: String { rawValue }

    var voiceCode: String {
        switch self {
        case .english: "en-IN"
        case .telugu: "te-IN"
        }
    }
}

@MainActor
@Observable
final class CallerViewModel {
    private(set) var game = HousieGame()
    private(set) var isDrawing = false
    var speechEnabled = true
    var announcementLanguage: AnnouncementLanguage = .english
    var callInterval = 6.0

    private let speaker = AVSpeechSynthesizer()
    private var automaticTask: Task<Void, Never>?

    var calledNumberSet: Set<Int> { Set(game.calledNumbers) }

    func togglePlayPause() {
        if game.status == .running {
            pause()
        } else {
            game.play()
            startAutomaticCalling()
        }
    }

    func pause() {
        game.pause()
        automaticTask?.cancel()
        automaticTask = nil
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
        }
        isDrawing = false
    }

    func reset() {
        automaticTask?.cancel()
        automaticTask = nil
        speaker.stopSpeaking(at: .immediate)
        isDrawing = false
        game.reset()
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
        speaker.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: String(number))
        utterance.voice = AVSpeechSynthesisVoice(language: announcementLanguage.voiceCode)
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.04
        speaker.speak(utterance)
    }
}
