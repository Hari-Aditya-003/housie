import XCTest

final class HousieUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCallerShowsCompleteBoardAndTVControl() {
        XCTAssertTrue(tab(named: "Caller").exists)
        XCTAssertTrue(tab(named: "How It Works").exists)
        XCTAssertFalse(tab(named: "Tickets").exists)
        XCTAssertEqual(app.staticTexts["calledCount"].label, "0 / 90")
        XCTAssertTrue(app.descendants(matching: .any)["airPlayRoutePicker"].exists)

        for number in 1...90 {
            XCTAssertTrue(
                app.descendants(matching: .any)["numberCell.\(number)"].exists,
                "Number \(number) should be visible on the caller board"
            )
        }
    }

    func testManualDrawAddsAVisibleNumberAndResetClearsIt() {
        app.buttons["nextBallButton"].tap()

        let oneCalled = app.staticTexts["calledCount"]
        XCTAssertTrue(waitForLabel("1 / 90", on: oneCalled, timeout: 6))

        let currentBall = app.descendants(matching: .any)["currentNumberBall"]
        XCTAssertTrue(currentBall.label.hasPrefix("Current number "))
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "identifier BEGINSWITH 'calledNumber.'"))
                .count,
            1
        )
        XCTAssertTrue(app.buttons["repeatButton"].isEnabled)
        app.buttons["repeatButton"].tap()

        app.buttons["resetButton"].tap()
        app.buttons["Reset all numbers"].tap()

        XCTAssertTrue(waitForLabel("0 / 90", on: oneCalled, timeout: 2))
        XCTAssertEqual(currentBall.label, "No number called")
        XCTAssertTrue(app.staticTexts["Called numbers will appear here"].exists)
    }

    func testPlayPauseAndCompactGuide() {
        let playPause = app.buttons["playPauseButton"]
        XCTAssertEqual(playPause.label, "Play")

        playPause.tap()
        XCTAssertTrue(waitForLabel("Pause", on: playPause, timeout: 2))
        XCTAssertEqual(app.staticTexts["callerStatus"].label, "Calling automatically")

        playPause.tap()
        XCTAssertTrue(waitForLabel("Play", on: playPause, timeout: 2))
        XCTAssertEqual(app.staticTexts["callerStatus"].label, "Game paused")

        tab(named: "How It Works").tap()
        XCTAssertTrue(app.staticTexts["howItWorksTitle"].waitForExistence(timeout: 2))

        for step in ["Start", "Listen", "Follow", "Share"] {
            XCTAssertTrue(app.staticTexts["guideStep.\(step)"].exists)
        }
    }

    private func tab(named name: String) -> XCUIElement {
        app.buttons[name].firstMatch
    }

    private func waitForLabel(
        _ label: String,
        on element: XCUIElement,
        timeout: TimeInterval
    ) -> Bool {
        let predicate = NSPredicate(format: "label == %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
