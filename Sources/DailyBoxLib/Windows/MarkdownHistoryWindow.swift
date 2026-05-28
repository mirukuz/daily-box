// Sources/DailyBoxLib/Windows/MarkdownHistoryWindow.swift
import AppKit

public final class MarkdownHistoryWindow: NSWindow {

    public init(markdown: String) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        self.title = "DailyBox History"
        self.isReleasedWhenClosed = false
        self.center()

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 24, height: 24)
        textView.autoresizingMask = [.width]

        textView.textStorage?.setAttributedString(styledAttributedString(from: markdown))

        scrollView.documentView = textView
        self.contentView = scrollView

        // Scroll to top
        textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
}

private func styledAttributedString(from markdown: String) -> NSAttributedString {
    let result = NSMutableAttributedString()
    let baseFont = NSFont.systemFont(ofSize: 13)
    let baseColor = NSColor.labelColor
    let mutedColor = NSColor.secondaryLabelColor

    for line in markdown.components(separatedBy: "\n") {
        let attr: NSAttributedString

        if line.hasPrefix("# ") {
            let text = String(line.dropFirst(2))
            attr = NSAttributedString(string: text + "\n", attributes: [
                .font: NSFont.boldSystemFont(ofSize: 18),
                .foregroundColor: baseColor
            ])
        } else if line.hasPrefix("## ") {
            let text = String(line.dropFirst(3))
            attr = NSAttributedString(string: "\n" + text + "\n", attributes: [
                .font: NSFont.boldSystemFont(ofSize: 14),
                .foregroundColor: baseColor
            ])
        } else if line.hasPrefix("**") && line.hasSuffix("**") {
            let text = String(line.dropFirst(2).dropLast(2))
            attr = NSAttributedString(string: text + "\n", attributes: [
                .font: NSFont.boldSystemFont(ofSize: 12),
                .foregroundColor: mutedColor
            ])
        } else if line.hasPrefix("  - ") {
            let text = String(line.dropFirst(4))
            attr = NSAttributedString(string: "      ◦ " + text + "\n", attributes: [
                .font: NSFont.systemFont(ofSize: 12),
                .foregroundColor: mutedColor
            ])
        } else if line.hasPrefix("- ") {
            let text = String(line.dropFirst(2))
            attr = NSAttributedString(string: "  • " + text + "\n", attributes: [
                .font: baseFont,
                .foregroundColor: baseColor
            ])
        } else if line.isEmpty {
            attr = NSAttributedString(string: "\n", attributes: [.font: baseFont])
        } else {
            attr = NSAttributedString(string: line + "\n", attributes: [
                .font: baseFont,
                .foregroundColor: baseColor
            ])
        }

        result.append(attr)
    }
    return result
}

public func formatHistoryMarkdown(_ records: [DayRecord]) -> String {
    guard !records.isEmpty else { return "No data yet." }

    let displayFmt = DateFormatter()
    displayFmt.dateFormat = "EEE, MMM d"

    var lines: [String] = ["# DailyBox", ""]

    for rec in records {
        let hasContent = !rec.todo.isEmpty || !rec.doing.isEmpty || !rec.done.isEmpty
        guard hasContent, let date = DayRecord.date(from: rec.date) else { continue }

        lines.append("## \(displayFmt.string(from: date))")

        func appendItems(_ items: [String]) {
            for it in items {
                lines.append("- \(it)")
                if let subs = rec.details[it], !subs.isEmpty {
                    subs.forEach { lines.append("  - \($0.isChecked ? "~~\($0.text)~~" : $0.text)") }
                }
            }
        }
        if !rec.done.isEmpty  { lines.append("**Done**");  appendItems(rec.done) }
        if !rec.doing.isEmpty { lines.append("**Doing**"); appendItems(rec.doing) }
        if !rec.todo.isEmpty  { lines.append("**Todo**");  appendItems(rec.todo) }
        lines.append("")
    }

    return lines.joined(separator: "\n")
}
