import Testing
import SnapshotTesting
import SwiftUI
import AppKit
@testable import SazBunnyCountdown

@MainActor
@Suite("UI Snapshots")
struct SnapshotTests {

    private func makeCountdownView(
        isFocused: Bool,
        timeString: String = "01:23:45",
        isFinished: Bool = false,
        targetTimeString: String? = "4:20 PM"
    ) -> NSView {
        let viewModel = CountdownViewModel()
        if isFinished {
            viewModel.timeString = "00:00"
            viewModel.isFinished = true
        } else {
            viewModel.timeString = timeString
        }
        viewModel.targetTimeString = targetTimeString
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = CountdownView(viewModel: viewModel, focusState: focusState, onDismiss: {}, onStartNew: {}, onRepeat: {})
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height)
        return hostingView
    }

    private func makeListeningView(
        isFocused: Bool,
        isListening: Bool = true,
        transcript: String = ""
    ) -> NSView {
        let speechRecognizer = SpeechRecognizer()
        speechRecognizer.transcript = transcript
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: focusState) {}
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: WindowConstants.width, height: WindowConstants.height)
        return hostingView
    }

    // MARK: - Countdown

    @Test("Countdown view with focus border")
    func countdownFocused() {
        let view = makeCountdownView(isFocused: true)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Countdown view without focus border")
    func countdownUnfocused() {
        let view = makeCountdownView(isFocused: false)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Countdown view in finished state")
    func countdownFinished() {
        let view = makeCountdownView(isFocused: true, isFinished: true)
        assertSnapshot(of: view, as: .image)
    }

    // MARK: - Listening

    @Test("Listening view in listening state")
    func listeningActive() {
        let view = makeListeningView(isFocused: true)
        assertSnapshot(of: view, as: .image)
    }

    @Test("Listening view with transcript")
    func listeningWithTranscript() {
        let view = makeListeningView(isFocused: false, transcript: "five twenty")
        assertSnapshot(of: view, as: .image)
    }
}
