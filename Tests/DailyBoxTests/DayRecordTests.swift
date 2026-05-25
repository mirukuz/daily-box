// Tests/DailyBoxTests/DayRecordTests.swift
import XCTest
@testable import DailyBoxLib

final class DayRecordTests: XCTestCase {

    func test_codableRoundtrip() throws {
        let record = DayRecord(
            date: "2026-05-26",
            todo: ["Review PR", "Write docs"],
            doing: ["Fix bug"],
            done: ["Deploy"],
            boxPosition: CGPoint(x: 100, y: 200),
            windowPosition: CGPoint(x: 50, y: 80),
            isClosed: true
        )
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(DayRecord.self, from: data)
        XCTAssertEqual(decoded, record)
    }

    func test_todayString_format() {
        let s = DayRecord.todayString()
        XCTAssertTrue(s.count == 10, "Expected YYYY-MM-DD format, got \(s)")
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 4)], "-")
        XCTAssertEqual(s[s.index(s.startIndex, offsetBy: 7)], "-")
    }

    func test_defaultInit_isEmpty() {
        let r = DayRecord.today()
        XCTAssertTrue(r.todo.isEmpty)
        XCTAssertTrue(r.doing.isEmpty)
        XCTAssertTrue(r.done.isEmpty)
        XCTAssertFalse(r.isClosed)
    }
}
