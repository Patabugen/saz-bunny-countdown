import AppKit
import Combine

class FloatingPanel: NSPanel {
    let focusState = PanelFocusState()
    private var localKeyMonitor: Any?
    private var shouldActivate = false

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 80),
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

        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isKeyWindow else { return event }
            if event.keyCode == 53 {
                (NSApp.delegate as? AppDelegate)?.dismissTimer()
                return nil
            } else if event.keyCode == 49 {
                (NSApp.delegate as? AppDelegate)?.showListening()
                return nil
            }
            return event
        }
    }

    deinit {
        if let monitor = localKeyMonitor { NSEvent.removeMonitor(monitor) }
    }

    override var canBecomeKey: Bool { shouldActivate }
    override var canBecomeMain: Bool { false }

    override func mouseDown(with event: NSEvent) {
        shouldActivate = true
        NSApp.activate(ignoringOtherApps: true)
        makeKey()
        super.mouseDown(with: event)
    }

    override func becomeKey() {
        super.becomeKey()
        focusState.isFocused = true
    }

    override func resignKey() {
        super.resignKey()
        focusState.isFocused = false
        shouldActivate = false
    }
}

class PanelFocusState: ObservableObject {
    @Published var isFocused = false
}
