import AppKit
import SwiftUI

@MainActor
class FloatingPanel: NSWindow {
    let focusState = PanelFocusState()
    weak var sizePreset: SizePreset?

    private var dragStartLocation: NSPoint?
    private var dragStartFrame: NSRect?
    private var lastScaleUpdate = CACurrentMediaTime()

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: SizePreset.baseWidth, height: SizePreset.baseHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.contentView = contentView
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
    }

    func installTrackingArea() {
        guard let contentView else { return }
        // Remove any previous tracking area we added
        for area in contentView.trackingAreas where area.owner === self {
            contentView.removeTrackingArea(area)
        }
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(trackingArea)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func becomeKey() {
        super.becomeKey()
        focusState.isFocused = true
    }

    override func resignKey() {
        super.resignKey()
        focusState.isFocused = false
    }

    // MARK: - Resize Handle

    private let resizeHitSize: CGFloat = 28

    private func isInResizeZone(_ point: NSPoint) -> Bool {
        // Bottom-right corner in window coordinates (origin is bottom-left)
        point.x >= frame.width - resizeHitSize && point.y <= resizeHitSize
    }

    override func mouseMoved(with event: NSEvent) {
        if isInResizeZone(event.locationInWindow) {
            if #available(macOS 15.0, *) {
                NSCursor.frameResize(position: .bottomRight, directions: .all).set()
            }
        } else {
            NSCursor.arrow.set()
        }
        super.mouseMoved(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
        super.mouseExited(with: event)
    }

    override func cursorUpdate(with event: NSEvent) {
        // Prevent AppKit from resetting cursor in the resize zone
        if isInResizeZone(event.locationInWindow) { return }
        super.cursorUpdate(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        if isInResizeZone(location) {
            dragStartLocation = convertPoint(toScreen: location)
            dragStartFrame = frame
            isMovableByWindowBackground = false
        } else {
            super.mouseDown(with: event)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startScreen = dragStartLocation,
              let startFrame = dragStartFrame,
              let sizePreset else {
            super.mouseDragged(with: event)
            return
        }

        let currentScreen = convertPoint(toScreen: event.locationInWindow)
        let deltaX = currentScreen.x - startScreen.x

        // Lock aspect ratio: derive new width from drag, compute height
        let newWidth = max(SizePreset.minWidth, min(SizePreset.maxWidth, startFrame.width + deltaX))
        let newHeight = newWidth / SizePreset.aspectRatio

        // Anchor top-left: adjust origin.y so the top edge stays fixed
        let newY = startFrame.origin.y + (startFrame.height - newHeight)

        let newFrame = NSRect(x: startFrame.origin.x, y: newY, width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)

        // Debounce SwiftUI relayout: update scale every ~100ms during drag
        let now = CACurrentMediaTime()
        if now - lastScaleUpdate > 0.05 {
            lastScaleUpdate = now
            sizePreset.scale = newWidth / SizePreset.baseWidth
        }
    }

    override func mouseUp(with event: NSEvent) {
        if dragStartLocation != nil {
            // Final precise update on release
            sizePreset?.scale = frame.width / SizePreset.baseWidth
            dragStartLocation = nil
            dragStartFrame = nil
            isMovableByWindowBackground = true
        } else {
            super.mouseUp(with: event)
        }
    }
}

@MainActor
class PanelFocusState: ObservableObject {
    @Published var isFocused = false
}
