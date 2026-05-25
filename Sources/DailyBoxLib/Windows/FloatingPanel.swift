// Sources/DailyBoxLib/Windows/FloatingPanel.swift
import AppKit
import SwiftUI

public final class FloatingPanel<Content: View>: NSPanel {

    private static var maxHeight: CGFloat { 600 }
    private let hostingController: NSHostingController<Content>

    public init(content: Content, width: CGFloat = 280) {
        hostingController = NSHostingController(rootView: content)

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: width, height: 100),
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

        let blur = NSVisualEffectView()
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.material = .hudWindow
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 14
        blur.layer?.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        let hostingView = hostingController.view
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 14
        hostingView.layer?.masksToBounds = true

        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 14
        container.layer?.masksToBounds = true

        container.addSubview(blur)
        container.addSubview(hostingView)

        // Both blur and hosting fill the container (= window frame).
        // The window is resized to match SwiftUI content height via sizeThatFits.
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blur.topAnchor.constraint(equalTo: container.topAnchor),
            blur.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: container.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        self.contentView = container

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit DailyBox", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        container.menu = menu

        // Observe layout changes on the hosting view to detect content height changes.
        hostingView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: hostingView,
            queue: .main
        ) { [weak self] _ in
            self?.fitToContent(width: width)
        }

        // Initial size after first layout pass.
        DispatchQueue.main.async { [weak self] in
            self?.fitToContent(width: width)
        }
    }

    private func fitToContent(width: CGFloat) {
        let natural = hostingController.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
        let newHeight = min(natural.height, Self.maxHeight)
        guard newHeight > 10, abs(newHeight - frame.height) > 1 else { return }
        let old = frame
        let newOriginY = old.origin.y + old.height - newHeight
        setFrame(
            NSRect(x: old.origin.x, y: newOriginY, width: old.width, height: newHeight),
            display: true,
            animate: false
        )
    }

    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { false }
}
