// Tests/DailyBoxTests/WeeklySummaryTests.swift
import XCTest
@testable import DailyBoxLib

final class WeeklySummaryTests: XCTestCase {

    func test_emptyRecords_returnsNoDataMessage() {
        let result = formatWeeklySummary([])
        XCTAssertEqual(result, "No data for this week.")
    }

    func test_singleDay_formatsCorrectly() {
        let record = DayRecord(date: "2026-05-26", todo: ["Write plan"], doing: ["Fix bug"], done: ["Deploy"])
        let result = formatWeeklySummary([record])
        XCTAssertTrue(result.contains("Tuesday"))
        XCTAssertTrue(result.contains("Done:  Deploy"))
        XCTAssertTrue(result.contains("Doing: Fix bug"))
        XCTAssertTrue(result.contains("Todo:  Write plan"))
    }

    func test_dayWithNoItems_isSkipped() {
        let emptyDay = DayRecord(date: "2026-05-26")
        let result = formatWeeklySummary([emptyDay])
        XCTAssertFalse(result.contains("Tuesday"))
    }

    func test_multipleItems_joinedByComma() {
        let record = DayRecord(date: "2026-05-26", todo: [], doing: [], done: ["Task A", "Task B"])
        let result = formatWeeklySummary([record])
        XCTAssertTrue(result.contains("Task A, Task B"))
    }
}
