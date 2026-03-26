import Testing
import SnapshotTesting
import SwiftUI
import AppKit
@testable import CountdownTimer

@MainActor
@Suite("UI Snapshots")
struct SnapshotTests {

    private func makeCountdownView(isFocused: Bool, timeString: String = "01:23:45", isFinished: Bool = false) -> NSView {
        let viewModel = CountdownViewModel()
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = CountdownView(viewModel: viewModel, focusState: focusState) {}
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: ClayTheme.windowWidth, height: ClayTheme.windowHeight)
        return hostingView
    }

    private func makeListeningView(isFocused: Bool, isListening: Bool = true, transcript: String = "") -> NSView {
        let speechRecognizer = SpeechRecognizer()
        speechRecognizer.transcript = transcript
        let focusState = PanelFocusState()
        focusState.isFocused = isFocused

        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: focusState) {}
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: ClayTheme.windowWidth, height: ClayTheme.windowHeight)
        return hostingView
    }

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
        let viewModel = CountdownViewModel()
        viewModel.timeString = "00:00"
        viewModel.isFinished = true
        viewModel.targetTimeString = "4:20 PM"
        let focusState = PanelFocusState()
        focusState.isFocused = true

        let view = CountdownView(viewModel: viewModel, focusState: focusState) {}
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: ClayTheme.windowWidth, height: ClayTheme.windowHeight)
        assertSnapshot(of: hostingView, as: .image)
    }

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
