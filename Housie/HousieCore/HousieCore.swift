public enum HousieGameStatus: String, Equatable, Sendable {
    case ready
    case running
    case paused
    case finished
}

public struct HousieGame: Equatable, Sendable {
    public private(set) var calledNumbers: [Int]
    public private(set) var remainingNumbers: [Int]
    public private(set) var currentNumber: Int?
    public private(set) var status: HousieGameStatus

    public init() {
        calledNumbers = []
        remainingNumbers = Array(1...90)
        currentNumber = nil
        status = .ready
    }

    public mutating func play() {
        guard !remainingNumbers.isEmpty else {
            status = .finished
            return
        }
        status = .running
    }

    public mutating func pause() {
        guard status == .running else { return }
        status = .paused
    }

    @discardableResult
    public mutating func drawNext() -> Int? {
        drawNext { upperBound in Int.random(in: 0..<upperBound) }
    }

    @discardableResult
    public mutating func drawNext(using indexPicker: (Int) -> Int) -> Int? {
        guard !remainingNumbers.isEmpty else {
            status = .finished
            return nil
        }

        let index = indexPicker(remainingNumbers.count)
        precondition(remainingNumbers.indices.contains(index), "Ball index is outside the remaining numbers")

        let number = remainingNumbers.remove(at: index)
        currentNumber = number
        calledNumbers.append(number)

        if remainingNumbers.isEmpty {
            status = .finished
        } else if status == .ready {
            status = .paused
        }

        return number
    }

    @discardableResult
    public mutating func drawAutomatically() -> Int? {
        drawAutomatically { upperBound in Int.random(in: 0..<upperBound) }
    }

    @discardableResult
    public mutating func drawAutomatically(using indexPicker: (Int) -> Int) -> Int? {
        guard status == .running else { return nil }
        return drawNext(using: indexPicker)
    }

    public mutating func reset() {
        self = HousieGame()
    }
}

public enum HousiePrize: String, CaseIterable, Identifiable, Sendable {
    case earlyFive = "Early Five"
    case topLine = "Top Line"
    case middleLine = "Middle Line"
    case bottomLine = "Bottom Line"
    case fullHouse = "Full House"

    public var id: String { rawValue }
}

public struct HousieTicket: Equatable, Sendable {
    public let rows: [[Int?]]

    public init(rows: [[Int?]]) {
        precondition(rows.count == 3, "A Housie ticket must have three rows")
        precondition(rows.allSatisfy { $0.count == 9 }, "A Housie ticket must have nine columns")
        self.rows = rows
    }

    public var numbers: [Int] {
        rows.flatMap { $0 }.compactMap(\.self)
    }

    public static func validRange(forColumn column: Int) -> ClosedRange<Int> {
        precondition((0..<9).contains(column), "Ticket columns are numbered from zero through eight")
        switch column {
        case 0: return 1...9
        case 8: return 80...90
        default: return (column * 10)...(column * 10 + 9)
        }
    }

    public func isWinning(_ prize: HousiePrize, calledNumbers: Set<Int>) -> Bool {
        switch prize {
        case .earlyFive:
            return calledNumbers.intersection(numbers).count >= 5
        case .topLine:
            return lineIsComplete(at: 0, calledNumbers: calledNumbers)
        case .middleLine:
            return lineIsComplete(at: 1, calledNumbers: calledNumbers)
        case .bottomLine:
            return lineIsComplete(at: 2, calledNumbers: calledNumbers)
        case .fullHouse:
            return Set(numbers).isSubset(of: calledNumbers)
        }
    }

    public static func generate() -> HousieTicket {
        var generator = SystemRandomNumberGenerator()
        return generate(using: &generator)
    }

    public static func generate(using generator: SeededGenerator) -> HousieTicket {
        var mutableGenerator = generator
        return generate(using: &mutableGenerator)
    }

    private func lineIsComplete(at row: Int, calledNumbers: Set<Int>) -> Bool {
        Set(rows[row].compactMap(\.self)).isSubset(of: calledNumbers)
    }

    private static func generate<G: RandomNumberGenerator>(using generator: inout G) -> HousieTicket {
        while true {
            var columnCounts = Array(repeating: 1, count: 9)
            for _ in 0..<6 {
                let eligible = columnCounts.indices.filter { columnCounts[$0] < 3 }
                let chosen = eligible.randomElement(using: &generator)!
                columnCounts[chosen] += 1
            }

            var occupied = Array(repeating: Array(repeating: false, count: 9), count: 3)
            var rowCounts = Array(repeating: 0, count: 3)
            var succeeded = true

            for column in columnCounts.indices.sorted(by: { columnCounts[$0] > columnCounts[$1] }) {
                let needed = columnCounts[column]
                let combinations = rowCombinations(taking: needed).shuffled(using: &generator)
                guard let rows = combinations.first(where: { combination in
                    combination.allSatisfy { rowCounts[$0] < 5 }
                }) else {
                    succeeded = false
                    break
                }

                for row in rows {
                    occupied[row][column] = true
                    rowCounts[row] += 1
                }
            }

            guard succeeded, rowCounts == [5, 5, 5] else { continue }

            var result = Array(repeating: Array<Int?>(repeating: nil, count: 9), count: 3)
            for column in 0..<9 {
                let targetRows = (0..<3).filter { occupied[$0][column] }
                let values = Array(validRange(forColumn: column))
                    .shuffled(using: &generator)
                    .prefix(targetRows.count)
                    .sorted()

                for (row, value) in zip(targetRows, values) {
                    result[row][column] = value
                }
            }

            return HousieTicket(rows: result)
        }
    }

    private static func rowCombinations(taking count: Int) -> [[Int]] {
        switch count {
        case 1: [[0], [1], [2]]
        case 2: [[0, 1], [0, 2], [1, 2]]
        default: [[0, 1, 2]]
        }
    }
}

public struct SeededGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64

    public init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}
