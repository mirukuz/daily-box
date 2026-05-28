// Sources/DailyBoxLib/Models/DayRecord.swift
import Foundation

public struct SubItem: Codable, Hashable {
    public var text: String
    public var isChecked: Bool

    public init(text: String, isChecked: Bool = false) {
        self.text = text
        self.isChecked = isChecked
    }
}

public struct DayRecord: Codable, Equatable {
    public var date: String          // "YYYY-MM-DD"
    public var todo: [String]
    public var doing: [String]
    public var done: [String]
    public var boxPosition: CGPoint
    public var windowPosition: CGPoint
    public var isClosed: Bool
    /// Sub-items keyed by parent item text.
    public var details: [String: [SubItem]]

    public init(
        date: String,
        todo: [String] = [],
        doing: [String] = [],
        done: [String] = [],
        boxPosition: CGPoint = CGPoint(x: 100, y: 100),
        windowPosition: CGPoint = CGPoint(x: -1, y: -1),
        isClosed: Bool = false,
        details: [String: [SubItem]] = [:]
    ) {
        self.date = date
        self.todo = todo
        self.doing = doing
        self.done = done
        self.boxPosition = boxPosition
        self.windowPosition = windowPosition
        self.isClosed = isClosed
        self.details = details
    }

    // MARK: - Codable (with migration from legacy [String] sub-items)

    enum CodingKeys: String, CodingKey {
        case date, todo, doing, done, boxPosition, windowPosition, isClosed, details
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = try c.decode(String.self, forKey: .date)
        todo = try c.decodeIfPresent([String].self, forKey: .todo) ?? []
        doing = try c.decodeIfPresent([String].self, forKey: .doing) ?? []
        done = try c.decodeIfPresent([String].self, forKey: .done) ?? []
        boxPosition = try c.decodeIfPresent(CGPoint.self, forKey: .boxPosition) ?? CGPoint(x: 100, y: 100)
        windowPosition = try c.decodeIfPresent(CGPoint.self, forKey: .windowPosition) ?? CGPoint(x: -1, y: -1)
        isClosed = try c.decodeIfPresent(Bool.self, forKey: .isClosed) ?? false
        // Migrate: try modern [SubItem] first, fall back to legacy [String]
        if let modern = try? c.decodeIfPresent([String: [SubItem]].self, forKey: .details) {
            details = modern ?? [:]
        } else if let legacy = try? c.decodeIfPresent([String: [String]].self, forKey: .details) {
            details = (legacy ?? [:]).mapValues { $0.map { SubItem(text: $0) } }
        } else {
            details = [:]
        }
    }

    public static func today() -> DayRecord {
        DayRecord(date: Self.todayString())
    }

    public static func todayString() -> String {
        dateFormatter.string(from: Date())
    }

    public static func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
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
