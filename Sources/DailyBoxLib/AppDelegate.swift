// Sources/DailyBoxLib/AppDelegate.swift
import AppKit
import SwiftUI
import ServiceManagement

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store = Store()
    private var mainPanel: FloatingPanel<MainView>?
    private var boxPanel: BoxPanel?
    private var summaryWindow: SummaryWindow?

    private let mainPanelSize = CGSize(width: 280, height: 400)

    public func applicationDidFinishLaunching(_ notification: Notification) {
        registerLoginItem()
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
        let panel = FloatingPanel(content: view, size: mainPanelSize)
        mainPanel = panel

        let origin = store.record.windowPosition
        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = max(0, min(origin.x, screen.width - mainPanelSize.width))
        let y = max(0, min(origin.y, screen.height - mainPanelSize.height))
        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.makeKeyAndOrderFront(nil)

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            guard let self, let panel = self.mainPanel else { return }
            self.store.updateWindowPosition(CGPoint(x: panel.frame.origin.x, y: panel.frame.origin.y))
        }
    }

    private func showBoxPanel() {
        mainPanel?.close()
        mainPanel = nil

        let box = BoxPanel(date: store.record.date)
        box.onTap = { [weak self] in self?.beginOpenRitual() }
        boxPanel = box

        let origin = store.record.boxPosition
        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = max(0, min(origin.x, screen.width - 52))
        let y = max(0, min(origin.y, screen.height - 62))
        box.setFrameOrigin(NSPoint(x: x, y: y))
        box.makeKeyAndOrderFront(nil)

        NotificationCenter.default.addObserver(
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
        let panel = FloatingPanel(content: view, size: mainPanelSize)
        mainPanel = panel

        let boxFrame = NSRect(x: boxOrigin.x, y: boxOrigin.y, width: 52, height: 62)
        panel.setFrame(boxFrame, display: false)
        panel.contentView?.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        boxPanel?.close()
        boxPanel = nil

        let targetOrigin = store.record.windowPosition
        CloseAnimator.open(panel: panel, targetSize: mainPanelSize, targetOrigin: targetOrigin) {}

        NotificationCenter.default.addObserver(
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

    // MARK: - Login Item

    private func registerLoginItem() {
        let key = "dailybox.loginItemPrompted"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

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
