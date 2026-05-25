// Sources/DailyBoxLib/Store/Store.swift
import Foundation
import Combine

@MainActor
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
