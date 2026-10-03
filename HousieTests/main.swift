import HousieCore

private var failures = 0

@MainActor
private func check(
    _ condition: @autoclosure () -> Bool,
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    if !condition() {
        failures += 1
        print("FAIL: \(message) at \(file):\(line)")
    }
}

@MainActor
private func testNewGameBeginsWithAllNinetyBallsAvailable() {
        let game = HousieGame()

        check(game.calledNumbers.isEmpty, "called numbers should be empty")
        check(game.remainingNumbers == Array(1...90), "all numbers should remain")
        check(game.currentNumber == nil, "current number should be nil")
        check(game.status == .ready, "game should be ready")
    }

@MainActor
private func testEveryBallIsCalledExactlyOnce() {
        var game = HousieGame()

        for _ in 1...90 {
            _ = game.drawNext(using: { _ in 0 })
        }

        check(game.calledNumbers == Array(1...90), "deterministic draw order should be stable")
        check(Set(game.calledNumbers).count == 90, "draws should be unique")
        check(game.remainingNumbers.isEmpty, "no balls should remain")
        check(game.status == .finished, "game should finish after 90 draws")
        check(game.drawNext(using: { _ in 0 }) == nil, "drawing after finish should return nil")
    }

@MainActor
private func testPauseStopsAutomaticDrawsButKeepsNextBallAvailable() {
        var game = HousieGame()
        game.play()
        game.pause()

        check(game.drawAutomatically(using: { _ in 0 }) == nil, "automatic draw should stop while paused")
        check(game.drawNext(using: { _ in 0 }) == 1, "manual next ball should remain available")
        check(game.status == .paused, "manual draw should keep the paused state")
    }

@MainActor
private func testResetRestoresTheOriginalCallerBoard() {
        var game = HousieGame()
        game.play()
        _ = game.drawNext(using: { _ in 20 })
        _ = game.drawNext(using: { _ in 40 })

        game.reset()

        check(game.calledNumbers.isEmpty, "called numbers should clear")
        check(game.remainingNumbers == Array(1...90), "all balls should return")
        check(game.currentNumber == nil, "current number should clear")
        check(game.status == .ready, "game should return to ready")
    }

@MainActor
private func testGeneratedTicketsFollowTheIndianHousieThreeByNineLayout() {
        let ticket = HousieTicket.generate(using: .init(seed: 2026))

        check(ticket.rows.count == 3, "ticket should have three rows")
        check(ticket.rows.allSatisfy { $0.count == 9 }, "ticket should have nine columns")
        check(ticket.rows.allSatisfy { row in row.compactMap(\.self).count == 5 }, "each row should contain five numbers")

        let numbers = ticket.rows.flatMap { $0 }.compactMap(\.self)
        check(numbers.count == 15, "ticket should contain 15 numbers")
        check(Set(numbers).count == 15, "ticket numbers should be unique")

        for column in 0..<9 {
            let values = ticket.rows.compactMap { $0[column] }
            let validRange = HousieTicket.validRange(forColumn: column)
            check(values.allSatisfy(validRange.contains), "column values should be in range")
            check(values == values.sorted(), "column values should be sorted")
        }
    }

@MainActor
private func testClaimsAreVerifiedOnlyAgainstNumbersAlreadyCalled() {
        let ticket = HousieTicket(rows: [
            [1, nil, 22, nil, 41, nil, 63, nil, 81],
            [nil, 14, 25, 36, nil, 55, nil, 72, nil],
            [8, 19, nil, 39, 48, nil, 69, nil, 90]
        ])

        check(ticket.isWinning(.earlyFive, calledNumbers: [1, 22, 41, 63, 81]), "early five should verify")
        check(ticket.isWinning(.topLine, calledNumbers: [1, 22, 41, 63, 81]), "top line should verify")
        check(!ticket.isWinning(.middleLine, calledNumbers: [1, 22, 41, 63, 81]), "middle line should fail")
        check(ticket.isWinning(.fullHouse, calledNumbers: Set(ticket.numbers)), "full house should verify")
    }

testNewGameBeginsWithAllNinetyBallsAvailable()
testEveryBallIsCalledExactlyOnce()
testPauseStopsAutomaticDrawsButKeepsNextBallAvailable()
testResetRestoresTheOriginalCallerBoard()
testGeneratedTicketsFollowTheIndianHousieThreeByNineLayout()
testClaimsAreVerifiedOnlyAgainstNumbersAlreadyCalled()

if failures == 0 {
    print("PASS: All HousieCore checks passed")
} else {
    fatalError("\(failures) HousieCore checks failed")
}
