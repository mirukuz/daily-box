// Sources/DailyBoxLib/Windows/BoxPanel.swift
import AppKit
import SwiftUI

public final class BoxPanel: NSPanel {
    public var onTap: (() -> Void)?

    public init(date: String) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 52, height: 62),
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
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true

        let boxView = BoxView(date: date)
        let hosting = NSHostingView(rootView: boxView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        blur.translatesAutoresizingMaskIntoConstraints = false

        let container = ClickableView()
        container.onTap = { [weak self] in self?.onTap?() }
        container.wantsLayer = true
        container.layer?.cornerRadius = 12
        container.layer?.masksToBounds = true

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

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit DailyBox", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        container.menu = menu
    }

    public override var canBecomeKey: Bool { true }
}

private final class ClickableView: NSView {
    var onTap: (() -> Void)?

    override func mouseUp(with event: NSEvent) {
        onTap?()
    }
}

private struct BoxView: View {
    let date: String

    var body: some View {
        VStack(spacing: 2) {
            Text("📦")
                .font(.system(size: 24))
            Text(shortDate)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(width: 52, height: 62)
    }

    private var shortDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: date) else { return self.date }
        let out = DateFormatter()
        out.dateFormat = "MMM d"
        return out.string(from: date)
    }
}
