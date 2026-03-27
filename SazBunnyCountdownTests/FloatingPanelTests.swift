import Testing
import AppKit
@testable import SazBunnyCountdown

@MainActor
@Suite("FloatingPanel")
struct FloatingPanelTests {

    @Test("focusState updates when becomeKey/resignKey are called")
    func focusStateUpdatesOnKeyChanges() {
        let panel = FloatingPanel(contentView: NSView())
        #expect(panel.focusState.isFocused == false)

        // Directly call becomeKey/resignKey to test the override behavior.
        // In production, AppKit calls these when the window gains/loses key status.
        panel.becomeKey()
        #expect(panel.focusState.isFocused == true)

        panel.resignKey()
        #expect(panel.focusState.isFocused == false)
    }
}
