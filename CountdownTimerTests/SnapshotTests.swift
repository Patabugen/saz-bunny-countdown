import Testing
import SnapshotTesting
import SwiftUI
import AppKit
@testable import CountdownTimer

@MainActor
@Suite("UI Snapshots")
struct SnapshotTests {

    private func makeThemeManager(style: ThemeStyle = .clay) -> ThemeManager {
        let manager = ThemeManager()
        manager.activeStyle = style
        return manager
    }

    private func makeCountdownView(
        isFocused: Bool,
        timeString: String = "01:23:45",
        isFinished: Bool = false,
        targetTimeString: String? = "4:20 PM",
        themeStyle: ThemeStyle = .clay
    ) -> NSView {
        let viewModel = CountdownViewModel()
        if isFinished {
            viewModel.timeString = "00:00"
            viewModel.isFinished = true
        }
        viewModel.targetTimeString = targetTimeString
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = CountdownView(viewModel: viewModel, focusState: focusState) {}
            .environmentObject(makeThemeManager(style: themeStyle))
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height)
        return hostingView
    }

    private func makeListeningView(
        isFocused: Bool,
        isListening: Bool = true,
        transcript: String = "",
        themeStyle: ThemeStyle = .clay
    ) -> NSView {
        let speechRecognizer = SpeechRecognizer()
        speechRecognizer.transcript = transcript
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: focusState) {}
            .environmentObject(makeThemeManager(style: themeStyle))
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height)
        return hostingView
    }

    // MARK: - Clay Theme

    @Test("Clay: Countdown view with focus border")
    func countdownFocused() {
        let view = makeCountdownView(isFocused: true)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Clay: Countdown view without focus border")
    func countdownUnfocused() {
        let view = makeCountdownView(isFocused: false)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Clay: Countdown view in finished state")
    func countdownFinished() {
        let view = makeCountdownView(isFocused: true, isFinished: true)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Clay: Listening view in listening state")
    func listeningActive() {
        let view = makeListeningView(isFocused: true)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Clay: Listening view with transcript")
    func listeningWithTranscript() {
        let view = makeListeningView(isFocused: false, transcript: "five twenty")
        assertSnapshot(of: view, as: .image)
    }

    // MARK: - Saz Bunny Theme

    @Test("SazBunny: Listening view")
    func sazBunnyListening() {
        let view = makeListeningView(isFocused: true, themeStyle: .sazBunny)
        assertSnapshot(of: view, as: .image)
    }

    @Test("SazBunny: Countdown view active")
    func sazBunnyCountdown() {
        let view = makeCountdownView(isFocused: true, themeStyle: .sazBunny)
        assertSnapshot(of: view, as: .image)
    }

    @Test("SazBunny: Countdown view expired")
    func sazBunnyExpired() {
        let view = makeCountdownView(isFocused: true, isFinished: true, themeStyle: .sazBunny)
        assertSnapshot(of: view, as: .image)
    }
}
