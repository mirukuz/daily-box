// Sources/DailyBoxLib/Animation/CloseAnimator.swift
import AppKit

public final class CloseAnimator {

    public static func close(panel: NSPanel, completion: @escaping (CGPoint) -> Void) {
        setAutoResize(panel, enabled: false)

        let originalFrame = panel.frame
        let boxFrame = NSRect(
            x: originalFrame.midX - 26,
            y: originalFrame.midY - 31,
            width: 52,
            height: 62
        )

        // Fade out content fully, then collapse frame simultaneously.
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.1
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.contentView?.animator().alphaValue = 0
        }, completionHandler: { [weak panel] in
            DispatchQueue.main.async {
                guard let panel else { return }
                // Collapse the (now invisible) frame to box size.
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.2
                    ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    panel.animator().setFrame(boxFrame, display: false, animate: true)
                }, completionHandler: { [weak panel] in
                    DispatchQueue.main.async {
                        guard panel != nil else { return }
                        completion(boxFrame.origin)
                    }
                })
            }
        })
    }

    public static func open(panel: NSPanel, targetSize: NSSize, targetOrigin: CGPoint, completion: @escaping () -> Void) {
        setAutoResize(panel, enabled: false)
        panel.contentView?.alphaValue = 0

        let fullFrame = NSRect(origin: targetOrigin, size: targetSize)

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(fullFrame, display: false, animate: true)
        }, completionHandler: { [weak panel] in
            DispatchQueue.main.async {
                guard let panel else { return }
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.12
                    panel.contentView?.animator().alphaValue = 1.0
                }, completionHandler: { [weak panel] in
                    DispatchQueue.main.async {
                        guard let panel else { return }
                        setAutoResize(panel, enabled: true)
                        completion()
                    }
                })
            }
        })
    }

    private static func setAutoResize(_ panel: NSPanel, enabled: Bool) {
        (panel as? AutoResizable)?.autoResizeEnabled = enabled
    }
}
