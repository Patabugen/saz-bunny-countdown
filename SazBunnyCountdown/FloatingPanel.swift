import AppKit
import Combine
import SwiftUI

class FloatingPanel: NSWindow {
    let focusState = PanelFocusState()

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height),
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
}

@MainActor
class PanelFocusState: ObservableObject {
    @Published var isFocused = false
}
