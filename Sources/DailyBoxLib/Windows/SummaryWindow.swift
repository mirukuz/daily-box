// Sources/DailyBoxLib/Windows/SummaryWindow.swift
import AppKit
import SwiftUI

public final class SummaryWindow: NSWindow {

    public init(text: String) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        self.title = "Weekly Summary"
        self.isReleasedWhenClosed = false
        self.contentView = NSHostingView(rootView: SummaryView(text: text))
        self.center()
    }
}
