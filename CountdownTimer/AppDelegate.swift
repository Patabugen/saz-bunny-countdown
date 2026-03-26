import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    let viewModel = CountdownViewModel()
    let speechRecognizer = SpeechRecognizer()
    private var launchedWithURL = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            if !launchedWithURL {
                showListening()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let panel = panel, panel.isVisible {
            panel.makeKeyAndOrderFront(nil)
        } else {
            showListening()
        }
        return true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        launchedWithURL = true
        guard let url = urls.first,
              let timeString = URLTimeParser.extractTime(from: url) else { return }
        handleTimeString(timeString)
    }

    func handleTimeString(_ timeString: String) {
        let result = TimeParser.parse(timeString)
        switch result {
        case .success(let date):
            showTimer(targetDate: date)
        case .needsConfirmation(let date, let message):
            showConfirmation(message: message) { [weak self] confirmed in
                if confirmed {
                    self?.showTimer(targetDate: date)
                }
            }
        case .failure(let message):
            showError(message)
        }
    }

    func showListening() {
        speechRecognizer.transcript = ""
        speechRecognizer.error = nil
        ensurePanel()

        guard let panel = panel else { return }
        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: panel.focusState) { [weak self] in
            self?.dismissTimer()
        }
        showPanel(content: view)

        speechRecognizer.startListening { [weak self] transcript in
            self?.handleSpeechResult(transcript)
        }
    }

    func showTimer(targetDate: Date) {
        speechRecognizer.stopListening()
        viewModel.start(targetDate: targetDate)
        ensurePanel()

        guard let panel = panel else { return }
        let view = CountdownView(viewModel: viewModel, focusState: panel.focusState) { [weak self] in
            self?.dismissTimer()
        }
        showPanel(content: view)
    }

    func dismissTimer() {
        saveCurrentScreen()
        viewModel.stop()
        speechRecognizer.stopListening()
        panel?.orderOut(nil)
        panel = nil
        NSApp.terminate(nil)
    }

    private func ensurePanel() {
        if panel == nil {
            panel = FloatingPanel(contentView: NSView())
        }
    }

    private func showPanel<V: View>(content: V) {
        let hostingView = NSHostingView(rootView: content)
        panel?.contentView = hostingView
        positionPanel()
        panel?.orderFront(nil)
        panel?.makeKey()
    }

    private func positionPanel() {
        guard let panel = panel else { return }

        let screen: NSScreen
        if let savedScreenNumber = UserDefaults.standard.object(forKey: "lastScreenNumber") as? Int,
           let matched = NSScreen.screens.first(where: { ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int) == savedScreenNumber }) {
            screen = matched
        } else {
            guard let fallback = NSScreen.main ?? NSScreen.screens.first else { return }
            screen = fallback
        }

        let visibleFrame = screen.visibleFrame
        let x = visibleFrame.maxX - panel.frame.width - 16
        let y = visibleFrame.maxY - panel.frame.height - 16
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func saveCurrentScreen() {
        guard let panel = panel, let screen = panel.screen else { return }
        if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? Int {
            UserDefaults.standard.set(screenNumber, forKey: "lastScreenNumber")
        }
    }

    private func handleSpeechResult(_ transcript: String) {
        let timeString = SpeechTimeExtractor.extractTime(from: transcript)
        handleTimeString(timeString)
    }

    private func showConfirmation(message: String, completion: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Confirm Timer"
        alert.informativeText = message
        alert.addButton(withTitle: "Start")
        alert.addButton(withTitle: "Cancel")
        completion(alert.runModal() == .alertFirstButtonReturn)
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.runModal()
    }
}
