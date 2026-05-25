// Sources/DailyBoxLib/Windows/FloatingPanel.swift
import AppKit
import SwiftUI

public final class FloatingPanel<Content: View>: NSPanel {

    public init(content: Content, size: CGSize = CGSize(width: 280, height: 400)) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hidesOnDeactivate = false

        // Glassmorphism background
        let blur = NSVisualEffectView()
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.material = .hudWindow
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 14
        blur.layer?.masksToBounds = true

        // SwiftUI content on top
        let hosting = NSHostingView(rootView: content)
        hosting.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 14
        container.layer?.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(blur)
        container.addSubview(hosting)

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blur.topAnchor.constraint(equalTo: container.topAnchor),
            blur.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            hosting.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: container.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        self.contentView = container

        // Context menu: Quit
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit DailyBox", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        container.menu = menu
    }

    // Accept mouse events even when app is not active
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { false }
}
