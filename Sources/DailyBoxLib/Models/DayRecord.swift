// Sources/DailyBoxLib/Models/DayRecord.swift
import Foundation

public struct DayRecord: Codable, Equatable {
    public var date: String          // "YYYY-MM-DD"
    public var todo: [String]
    public var doing: [String]
    public var done: [String]
    public var boxPosition: CGPoint
    public var windowPosition: CGPoint
    public var isClosed: Bool

    public init(
        date: String,
        todo: [String] = [],
        doing: [String] = [],
        done: [String] = [],
        boxPosition: CGPoint = CGPoint(x: 100, y: 100),
        windowPosition: CGPoint = CGPoint(x: 100, y: 100),
        isClosed: Bool = false
    ) {
        self.date = date
        self.todo = todo
        self.doing = doing
        self.done = done
        self.boxPosition = boxPosition
        self.windowPosition = windowPosition
        self.isClosed = isClosed
    }

    public static func today() -> DayRecord {
        DayRecord(date: Self.todayString())
    }

    public static func todayString() -> String {
        dateFormatter.string(from: Date())
    }

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
}

extension CGPoint: @retroactive Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Double.self)
        let y = try container.decode(Double.self)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(Double(x))
        try container.encode(Double(y))
    }
}

extension CGPoint: @retroactive Equatable {
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}
