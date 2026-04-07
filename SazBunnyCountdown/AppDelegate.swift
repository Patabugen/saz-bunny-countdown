import AppKit
import os.log
import SwiftUI

private let log = Logger(subsystem: "com.patabugen.sazbunnycountdown", category: "AppDelegate")

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private static let lastScreenNumberKey = "lastScreenNumber"

    private var panel: FloatingPanel?
    let viewModel = CountdownViewModel()
    private var speechRecognizer: SpeechRecognizer?
    let sizePreset = SizePreset()
    private var launchedWithURL = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.info("didFinishLaunching – args: \(CommandLine.arguments, privacy: .public)")

        // Skip UI setup when running as a test host.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            log.info("Running as test host – skipping UI")
            return
        }

        // Support launching with a time string as a CLI argument (e.g. "3pm").
        if CommandLine.arguments.count > 1 {
            let timeString = CommandLine.arguments[1]
            log.info("CLI arg time: \(timeString, privacy: .public)")
            launchedWithURL = true
            handleTimeString(timeString)
            return
        }

        // application(_:open:) is delivered on the same run loop iteration
        // as didFinishLaunching when the app is launched via URL. Deferring
        // to the next cycle ensures the URL handler has already fired.
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.launchedWithURL else { return }
            log.info("No URL – showing listening view")
            self.showListening()
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
        log.info("Parsing time: \(timeString, privacy: .public)")
        let result = TimeParser.parse(timeString)
        switch result {
        case .success(let date):
            log.info("Parsed OK – target: \(date, privacy: .public)")
            showTimer(targetDate: date, originalInput: timeString)
        case .failure(let message):
            log.error("Parse failed: \(message, privacy: .public)")
            showListening(errorMessage: message)
        }
    }

    private var parseError: String?

    func showListening(errorMessage: String? = nil) {
        if speechRecognizer == nil { speechRecognizer = SpeechRecognizer() }
        guard let speechRecognizer else { return }

        speechRecognizer.transcript = ""
        speechRecognizer.error = nil
        parseError = errorMessage
        ensurePanel()

        guard let panel = panel else { return }
        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: panel.focusState, parseError: parseError) { [weak self] in
            self?.dismissTimer()
        }
        showPanel(content: view)

        Task {
            try? await Task.sleep(for: .milliseconds(200))
            speechRecognizer.startListening { [weak self] transcript in
                self?.handleSpeechResult(transcript)
            }
        }
    }

    func showTimer(targetDate: Date, originalInput: String? = nil) {
        speechRecognizer?.stopListening()
        viewModel.start(targetDate: targetDate, originalInput: originalInput)
        ensurePanel()

        guard let panel = panel else { return }
        let view = CountdownView(viewModel: viewModel, focusState: panel.focusState, onDismiss: { [weak self] in
            self?.dismissTimer()
        }, onStartNew: { [weak self] in
            self?.viewModel.stop()
            self?.showListening()
        }, onRepeat: { [weak self] in
            guard let self,
                  let repeatDate = self.viewModel.repeatTargetDate else { return }
            let input = self.viewModel.originalInput
            self.showTimer(targetDate: repeatDate, originalInput: input)
        })
        showPanel(content: view)
    }

    func dismissTimer() {
        saveCurrentScreen()
        viewModel.stop()
        speechRecognizer?.stopListening()
        panel?.orderOut(nil)
        panel = nil
        NSApp.terminate(nil)
    }

    private func ensurePanel() {
        if panel == nil {
            let newPanel = FloatingPanel(contentView: NSView())
            newPanel.sizePreset = sizePreset
            panel = newPanel
        }
    }

    private func showPanel<V: View>(content: V) {
        let hostingView = NSHostingView(
            rootView: content.environmentObject(sizePreset)
        )
        panel?.contentView = hostingView
        resizeAndPositionPanel()
        panel?.orderFront(nil)
        panel?.makeKey()
    }

    private func resizeAndPositionPanel() {
        guard let panel = panel else { return }
        let newSize = NSSize(width: sizePreset.windowWidth, height: sizePreset.windowHeight)
        panel.setFrame(NSRect(origin: panel.frame.origin, size: newSize), display: true)
        positionPanel()
    }

    private func positionPanel() {
        guard let panel = panel else { return }

        let screen: NSScreen
        if let savedScreenNumber = UserDefaults.standard.object(forKey: Self.lastScreenNumberKey) as? Int,
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
            UserDefaults.standard.set(screenNumber, forKey: Self.lastScreenNumberKey)
        }
    }

    private func handleSpeechResult(_ transcript: String) {
        let timeString = SpeechTimeExtractor.extractTime(from: transcript)
        handleTimeString(timeString)
    }

}
