// Sources/DailyBoxLib/Store/Store.swift
import Foundation
import Combine

public final class Store: ObservableObject {
    @Published public var record: DayRecord

    private let directory: URL

    public init(directory: URL? = nil) {
        self.directory = directory ?? Self.defaultDirectory()
        self.record = DayRecord.today()
        self.record = load(from: self.directory)
    }

    // MARK: - Public

    public func save() {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = fileURL(for: record.date)
            let data = try JSONEncoder().encode(record)
            try data.write(to: url, options: .atomic)
        } catch {
            print("DailyBox: save failed: \(error)")
        }
    }

    public func addItem(_ text: String, to section: Section) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        switch section {
        case .todo:  record.todo.append(trimmed)
        case .doing: record.doing.append(trimmed)
        case .done:  record.done.append(trimmed)
        }
        save()
    }

    public func moveItem(_ text: String, from: Section, to: Section) {
        removeItem(text, from: from)
        switch to {
        case .todo:  record.todo.append(text)
        case .doing: record.doing.append(text)
        case .done:  record.done.append(text)
        }
        save()
    }

    private func removeItem(_ text: String, from section: Section) {
        switch section {
        case .todo:  record.todo.removeAll { $0 == text }
        case .doing: record.doing.removeAll { $0 == text }
        case .done:  record.done.removeAll { $0 == text }
        }
    }

    public func markClosed(_ closed: Bool) {
        record.isClosed = closed
        save()
    }

    public func updateBoxPosition(_ point: CGPoint) {
        record.boxPosition = point
        save()
    }

    public func updateWindowPosition(_ point: CGPoint) {
        record.windowPosition = point
        save()
    }

    /// All saved day records sorted oldest-first, weekends excluded.
    public func allRecords() -> [DayRecord] {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil
        )) ?? []
        let cal = Calendar.current
        return files
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .compactMap { url -> DayRecord? in
                guard let data = try? Data(contentsOf: url),
                      let rec = try? JSONDecoder().decode(DayRecord.self, from: data) else { return nil }
                return rec
            }
            .filter { rec in
                guard let date = DayRecord.date(from: rec.date) else { return true }
                let w = cal.component(.weekday, from: date)
                return w != 1 && w != 7  // exclude Sunday (1) and Saturday (7)
            }
    }

    public func record(daysAgo: Int) -> DayRecord? {
        guard daysAgo > 0 else { return nil }
        let cal = Calendar.current
        guard let date = cal.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let url = fileURL(for: fmt.string(from: date))
        guard let data = try? Data(contentsOf: url),
              let rec = try? JSONDecoder().decode(DayRecord.self, from: data) else { return nil }
        return rec
    }

    // MARK: - Week data (for summary)

    public func weekRecords() -> [DayRecord] {
        let calendar = Calendar.current
        let today = Date()
        guard let monday = calendar.date(from: calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: today)) else { return [] }

        return (0..<5).compactMap { offset -> DayRecord? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else { return nil }
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            let dateStr = fmt.string(from: day)
            let url = fileURL(for: dateStr)
            guard let data = try? Data(contentsOf: url),
                  let rec = try? JSONDecoder().decode(DayRecord.self, from: data) else { return nil }
            return rec
        }
    }

    // MARK: - Private

    private func load(from dir: URL) -> DayRecord {
        let today = DayRecord.todayString()

        // Find most recent saved file
        let files = (try? FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.contentModificationDateKey]
        )) ?? []

        let sorted = files
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }

        guard let latest = sorted.first,
              let data = try? Data(contentsOf: latest),
              let saved = try? JSONDecoder().decode(DayRecord.self, from: data)
        else {
            return DayRecord.today()
        }

        if saved.date == today {
            return saved
        } else {
            // New day: carry over todo + doing, clear done
            var newRecord = DayRecord.today()
            newRecord.todo = saved.todo
            newRecord.doing = saved.doing
            newRecord.done = []
            newRecord.windowPosition = saved.windowPosition
            newRecord.boxPosition = saved.boxPosition
            newRecord.isClosed = false
            return newRecord
        }
    }

    private func fileURL(for date: String) -> URL {
        directory.appendingPathComponent("\(date).json")
    }

    private static func defaultDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DailyBox")
    }
}

public enum Section: String, CaseIterable {
    case todo, doing, done

    public var label: String { rawValue.uppercased() }
}

public func formatWeeklySummary(_ records: [DayRecord]) -> String {
    guard !records.isEmpty else { return "No data for this week." }

    let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd"

    var lines: [String] = []

    // Header: "Week of May 26 – May 30"
    if let first = records.first, let last = records.last,
       let firstDate = fmt.date(from: first.date),
       let lastDate = fmt.date(from: last.date) {
        let display = DateFormatter()
        display.dateFormat = "MMM d"
        lines.append("Week of \(display.string(from: firstDate)) – \(display.string(from: lastDate))")
        lines.append("")
    }

    for record in records {
        guard let date = fmt.date(from: record.date) else { continue }
        let weekday = Calendar.current.component(.weekday, from: date)
        // weekday: 1=Sun, 2=Mon, ..., 6=Fri
        let name = weekday >= 2 && weekday <= 6 ? dayNames[weekday - 2] : record.date

        let hasContent = !record.todo.isEmpty || !record.doing.isEmpty || !record.done.isEmpty
        guard hasContent else { continue }

        lines.append(name)
        if !record.done.isEmpty {
            lines.append("  Done:  " + record.done.joined(separator: ", "))
        }
        if !record.doing.isEmpty {
            lines.append("  Doing: " + record.doing.joined(separator: ", "))
        }
        if !record.todo.isEmpty {
            lines.append("  Todo:  " + record.todo.joined(separator: ", "))
        }
        lines.append("")
    }

    return lines.joined(separator: "\n").trimmingCharacters(in: .newlines)
}
