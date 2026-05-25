// Sources/DailyBox/AppDelegate.swift
import AppKit
import SwiftUI
import ServiceManagement
import DailyBoxLib

class AppDelegate: NSObject, NSApplicationDelegate {
    private var store = Store()
    private var mainPanel: FloatingPanel<MainView>?
    private var boxPanel: BoxPanel?
    private var summaryWindow: SummaryWindow?
    private var markdownWindow: MarkdownHistoryWindow?
    private var statusItem: NSStatusItem?
    private var mainPanelObserver: NSObjectProtocol?
    private var boxPanelObserver: NSObjectProtocol?

    private let mainPanelSize = CGSize(width: 280, height: 400)

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerLoginItem()
        setupStatusItem()
        if store.record.isClosed {
            showBoxPanel()
        } else {
            showMainPanel()
        }
    }

    // MARK: - Show/Hide

    private func showMainPanel() {
        boxPanel?.close()
        boxPanel = nil

        let view = MainView(
            store: store,
            onClose: { [weak self] in self?.beginCloseRitual() },
            onWeeklySummary: { [weak self] in self?.showWeeklySummary() }
        )
        let panel = FloatingPanel(content: view, width: 280)
        mainPanel = panel

        let saved = store.record.windowPosition
        let mainScreen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let topMargin: CGFloat = 20
        let rightMargin: CGFloat = 20
        let initialHeight: CGFloat = 100
        let defaultX = mainScreen.maxX - mainPanelSize.width - rightMargin
        let defaultY = mainScreen.maxY - topMargin - initialHeight
        let rawX = saved.x < 0 ? defaultX : saved.x
        let rawY = saved.y < 0 ? defaultY : saved.y
        let screen = screenFrame(containing: CGPoint(x: rawX, y: rawY))
        let x = max(screen.minX, min(rawX, screen.maxX - mainPanelSize.width))
        let y = max(screen.minY, min(rawY, screen.maxY - mainPanelSize.height))
        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if let old = mainPanelObserver { NotificationCenter.default.removeObserver(old) }
        mainPanelObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            guard let self, let panel = self.mainPanel else { return }
            self.store.updateWindowPosition(CGPoint(x: panel.frame.origin.x, y: panel.frame.origin.y))
        }
    }

    private func showBoxPanel() {
        mainPanel?.orderOut(nil)
        mainPanel = nil

        let box = BoxPanel(date: store.record.date)
        box.onTap = { [weak self] in self?.beginOpenRitual() }
        boxPanel = box

        let origin = store.record.boxPosition
        let screen = screenFrame(containing: origin)
        let x = max(screen.minX, min(origin.x, screen.maxX - 52))
        let y = max(screen.minY, min(origin.y, screen.maxY - 62))
        box.setFrameOrigin(NSPoint(x: x, y: y))
        box.makeKeyAndOrderFront(nil)

        if let old = boxPanelObserver { NotificationCenter.default.removeObserver(old) }
        boxPanelObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: box,
            queue: .main
        ) { [weak self] _ in
            guard let self, let box = self.boxPanel else { return }
            self.store.updateBoxPosition(CGPoint(x: box.frame.origin.x, y: box.frame.origin.y))
        }
    }

    // MARK: - Animations

    private func beginCloseRitual() {
        guard let panel = mainPanel else { return }
        store.markClosed(true)

        CloseAnimator.close(panel: panel) { [weak self] finalPosition in
            guard let self else { return }
            self.store.updateBoxPosition(finalPosition)
            self.showBoxPanel()
        }
    }

    private func beginOpenRitual() {
        store = Store()

        let boxOrigin = boxPanel?.frame.origin ?? CGPoint(x: 100, y: 100)

        let view = MainView(
            store: store,
            onClose: { [weak self] in self?.beginCloseRitual() },
            onWeeklySummary: { [weak self] in self?.showWeeklySummary() }
        )
        let panel = FloatingPanel(content: view, width: 280)
        mainPanel = panel

        let boxFrame = NSRect(x: boxOrigin.x, y: boxOrigin.y, width: 52, height: 62)
        panel.setFrame(boxFrame, display: false)
        panel.contentView?.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        boxPanel?.close()
        boxPanel = nil

        let rawOrigin = store.record.windowPosition
        // Expand back onto the same screen the box is on
        let screen = screenFrame(containing: boxOrigin)
        let targetOrigin = CGPoint(
            x: max(screen.minX, min(rawOrigin.x < 0 ? boxOrigin.x : rawOrigin.x, screen.maxX - mainPanelSize.width)),
            y: max(screen.minY, min(rawOrigin.y < 0 ? boxOrigin.y : rawOrigin.y, screen.maxY - mainPanelSize.height))
        )
        CloseAnimator.open(panel: panel, targetSize: mainPanelSize, targetOrigin: targetOrigin) {}

        if let old = mainPanelObserver { NotificationCenter.default.removeObserver(old) }
        mainPanelObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            guard let self, let panel = self.mainPanel else { return }
            self.store.updateWindowPosition(CGPoint(x: panel.frame.origin.x, y: panel.frame.origin.y))
        }
    }

    // MARK: - Weekly Summary

    private func showWeeklySummary() {
        let records = store.weekRecords()
        let text = formatWeeklySummary(records)
        summaryWindow = SummaryWindow(text: text)
        summaryWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "tray.fill", accessibilityDescription: "DailyBox")
            button.image?.isTemplate = true
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "View in Markdown", action: #selector(showMarkdownHistory), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit DailyBox", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
    }

    @objc private func showMarkdownHistory() {
        let records = store.allRecords()
        let markdown = formatHistoryMarkdown(records)
        markdownWindow = MarkdownHistoryWindow(markdown: markdown)
        markdownWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Helpers

    /// Returns the frame of the screen containing the given point, falling back to main screen.
    private func screenFrame(containing point: CGPoint) -> NSRect {
        NSScreen.screens.first { $0.frame.contains(point) }?.frame
            ?? NSScreen.main?.frame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
    }

    // MARK: - Login Item

    private func registerLoginItem() {
        let key = "dailybox.loginItemPrompted"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Launch DailyBox at login?"
        alert.informativeText = "DailyBox will start automatically when you log in."
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        if alert.runModal() == .alertFirstButtonReturn {
            try? SMAppService.mainApp.register()
        }
    }
}
