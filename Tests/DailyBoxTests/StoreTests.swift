// Tests/DailyBoxTests/StoreTests.swift
import XCTest
@testable import DailyBoxLib

final class StoreTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DailyBoxTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func test_addItem_savesAndLoads() throws {
        let store = Store(directory: tempDir)
        store.addItem("Write tests", to: .todo)

        let store2 = Store(directory: tempDir)
        XCTAssertTrue(store2.record.todo.contains("Write tests"))
    }

    func test_moveItem_betweenSections() {
        let store = Store(directory: tempDir)
        store.addItem("Fix bug", to: .todo)
        store.moveItem("Fix bug", from: .todo, to: .doing)

        XCTAssertFalse(store.record.todo.contains("Fix bug"))
        XCTAssertTrue(store.record.doing.contains("Fix bug"))
    }

    func test_dayTransition_carriesOverTodoAndDoing_clearsDone() throws {
        // Write a "yesterday" file
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayStr = fmt.string(from: yesterday)

        var oldRecord = DayRecord(date: yesterdayStr)
        oldRecord.todo = ["Old todo"]
        oldRecord.doing = ["Old doing"]
        oldRecord.done = ["Old done"]

        let url = tempDir.appendingPathComponent("\(yesterdayStr).json")
        let data = try JSONEncoder().encode(oldRecord)
        try data.write(to: url)

        let store = Store(directory: tempDir)

        XCTAssertEqual(store.record.date, DayRecord.todayString())
        XCTAssertEqual(store.record.todo, ["Old todo"])
        XCTAssertEqual(store.record.doing, ["Old doing"])
        XCTAssertTrue(store.record.done.isEmpty)
    }

    func test_addItem_ignoresBlankString() {
        let store = Store(directory: tempDir)
        store.addItem("   ", to: .todo)
        XCTAssertTrue(store.record.todo.isEmpty)
    }
}
