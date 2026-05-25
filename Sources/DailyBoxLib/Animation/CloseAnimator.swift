// Sources/DailyBoxLib/Animation/CloseAnimator.swift
import AppKit

public final class CloseAnimator {

    /// Animates the main panel collapsing into a 52×52 box.
    /// - Parameters:
    ///   - panel: The main FloatingPanel to animate
    ///   - completion: Called when animation ends; switch to BoxPanel here
    public static func close(panel: NSPanel, completion: @escaping (CGPoint) -> Void) {
        let originalFrame = panel.frame
        let centerX = originalFrame.midX
        let centerY = originalFrame.midY

        // Step 1: fade content (0.3s)
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.contentView?.animator().alphaValue = 0.2
        }, completionHandler: { [weak panel] in
            DispatchQueue.main.async {
                guard let panel = panel else { return }

                // Step 2+3: collapse to small square (0.7s)
                let boxFrame = NSRect(
                    x: centerX - 26,
                    y: centerY - 31,
                    width: 52,
                    height: 62
                )
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.7
                    ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    panel.animator().setFrame(boxFrame, display: true, animate: true)
                }, completionHandler: { [weak panel] in
                    DispatchQueue.main.async {
                        guard panel != nil else { return }
                        let origin = boxFrame.origin
                        completion(CGPoint(x: origin.x, y: origin.y))
                    }
                })
            }
        })
    }

    /// Animates from 52×52 back to full panel size.
    /// - Parameters:
    ///   - panel: The main FloatingPanel (must be at box-size position already)
    ///   - targetSize: The full window size to expand to
    ///   - completion: Called when animation ends
    public static func open(panel: NSPanel, targetSize: NSSize, targetOrigin: CGPoint, completion: @escaping () -> Void) {
        panel.contentView?.alphaValue = 0

        let fullFrame = NSRect(
            x: targetOrigin.x,
            y: targetOrigin.y,
            width: targetSize.width,
            height: targetSize.height
        )

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.8
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(fullFrame, display: true, animate: true)
        }, completionHandler: { [weak panel] in
            DispatchQueue.main.async {
                guard let panel = panel else { return }
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.2
                    panel.contentView?.animator().alphaValue = 1.0
                }, completionHandler: { [weak panel] in
                    DispatchQueue.main.async {
                        guard panel != nil else { return }
                        completion()
                    }
                })
            }
        })
    }
}
