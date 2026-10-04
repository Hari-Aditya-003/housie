import GoogleCast
import Observation
import SwiftUI
import UIKit

private enum HousieCastConfiguration {
    static let namespace = "urn:x-cast:com.housie.board"

    static var receiverApplicationID: String {
        Bundle.main.object(forInfoDictionaryKey: "GCKReceiverApplicationID") as? String
            ?? "YOUR_GOOGLE_CAST_RECEIVER_APP_ID"
    }
}

private struct CastBoardState: Codable {
    let calledNumbers: [Int]
    let currentNumber: Int?
    let status: String
}

@MainActor
@Observable
final class GoogleCastManager: NSObject {
    static let shared = GoogleCastManager()

    private(set) var isConnected = false

    @ObservationIgnored private let channel = HousieCastChannel(
        namespace: HousieCastConfiguration.namespace
    )
    @ObservationIgnored private var latestState = CastBoardState(
        calledNumbers: [],
        currentNumber: nil,
        status: HousieGameStatus.ready.rawValue
    )
    @ObservationIgnored private var isListening = false

    func start() {
        guard !isListening else { return }
        isListening = true

        let sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)

        if let session = sessionManager.currentCastSession {
            connect(to: session)
        }
    }

    func publish(game: HousieGame) {
        latestState = CastBoardState(
            calledNumbers: game.calledNumbers,
            currentNumber: game.currentNumber,
            status: game.status.rawValue
        )
        channel.send(latestState)
    }

    private func connect(to session: GCKCastSession) {
        session.add(channel)
        isConnected = true
        channel.send(latestState)
    }

    private func disconnect(from session: GCKSession) {
        if let castSession = session as? GCKCastSession {
            castSession.remove(channel)
        }
        isConnected = false
    }
}

extension GoogleCastManager: @MainActor GCKSessionManagerListener {
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        guard let castSession = session as? GCKCastSession else { return }
        connect(to: castSession)
    }

    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        guard let castSession = session as? GCKCastSession else { return }
        connect(to: castSession)
    }

    func sessionManager(_: GCKSessionManager, didEnd session: GCKSession, withError _: Error?) {
        disconnect(from: session)
    }

    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError _: Error?) {
        isConnected = false
    }
}

private final class HousieCastChannel: GCKCastChannel {
    private var pendingMessage: String?

    func send(_ state: CastBoardState) {
        guard let data = try? JSONEncoder().encode(state),
              let message = String(data: data, encoding: .utf8)
        else { return }

        pendingMessage = message
        flushPendingMessage()
    }

    override func didConnect() {
        super.didConnect()
        flushPendingMessage()
    }

    override func didChangeWritableState(_ isWritable: Bool) {
        super.didChangeWritableState(isWritable)
        if isWritable { flushPendingMessage() }
    }

    private func flushPendingMessage() {
        guard isWritable, let message = pendingMessage else { return }

        var error: GCKError?
        if sendTextMessage(message, error: &error) {
            pendingMessage = nil
        }
    }
}

final class CastAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let criteria = GCKDiscoveryCriteria(
            applicationID: HousieCastConfiguration.receiverApplicationID
        )
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.startDiscoveryAfterFirstTapOnCastButton = true
        GCKCastContext.setSharedInstanceWith(options)
        GoogleCastManager.shared.start()
        return true
    }
}

struct GoogleCastButton: UIViewRepresentable {
    func makeUIView(context _: Context) -> GCKUICastButton {
        let button = GCKUICastButton(frame: .zero)
        button.tintColor = UIColor(HousieTheme.magenta)
        button.accessibilityLabel = "Cast Housie to Android or Google TV"
        button.accessibilityIdentifier = "googleCastButton"
        return button
    }

    func updateUIView(_ button: GCKUICastButton, context _: Context) {
        button.tintColor = UIColor(HousieTheme.magenta)
    }
}
