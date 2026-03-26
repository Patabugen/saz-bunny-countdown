import AppKit
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    let viewModel = CountdownViewModel()
    let speechRecognizer = SpeechRecognizer()
    private var launchedWithURL = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

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
              url.scheme == "countdown" else { return }
        if let host = url.host {
            var timeString = host
            if let port = url.port {
                timeString += ":\(port)"
            }
            handleTimeString(timeString)
        }
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

        let view = ListeningView(speechRecognizer: speechRecognizer, focusState: panel!.focusState) { [weak self] in
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

        let view = CountdownView(viewModel: viewModel, focusState: panel!.focusState) { [weak self] in
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
            screen = NSScreen.main ?? NSScreen.screens[0]
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
        let timeString = extractTime(from: transcript)
        handleTimeString(timeString)
    }

    private func extractTime(from transcript: String) -> String {
        let lower = transcript.lowercased()

        let digitPattern = #"(\d{1,2}:\d{2}\s*(?:am|pm|a\.m|p\.m)?|\d{1,2}\s*(?:am|pm|a\.m|p\.m))"#
        if let range = lower.range(of: digitPattern, options: .regularExpression) {
            return String(lower[range])
        }

        let wordNumbers: [String: Int] = [
            "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
            "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
            "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14,
            "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18,
            "nineteen": 19, "twenty": 20, "thirty": 30, "forty": 40,
            "fifty": 50,
        ]

        let compound: [String: Int] = [
            "twenty one": 21, "twenty two": 22, "twenty three": 23,
            "twenty four": 24, "twenty five": 25, "twenty six": 26,
            "twenty seven": 27, "twenty eight": 28, "twenty nine": 29,
            "thirty one": 31, "thirty two": 32, "thirty three": 33,
            "thirty four": 34, "thirty five": 35, "thirty six": 36,
            "thirty seven": 37, "thirty eight": 38, "thirty nine": 39,
            "forty one": 41, "forty two": 42, "forty three": 43,
            "forty four": 44, "forty five": 45, "forty six": 46,
            "forty seven": 47, "forty eight": 48, "forty nine": 49,
            "fifty one": 51, "fifty two": 52, "fifty three": 53,
            "fifty four": 54, "fifty five": 55, "fifty six": 56,
            "fifty seven": 57, "fifty eight": 58, "fifty nine": 59,
        ]

        let words = lower.components(separatedBy: .whitespaces)
        var hour: Int?
        var minute: Int = 0
        var ampm = ""

        if lower.contains(" am") || lower.contains(" a.m") { ampm = "am" }
        if lower.contains(" pm") || lower.contains(" p.m") { ampm = "pm" }

        for i in 0..<words.count {
            if hour != nil && i + 1 < words.count {
                let twoWord = "\(words[i]) \(words[i + 1])"
                if let m = compound[twoWord] {
                    minute = m
                    break
                }
            }

            if let num = wordNumbers[words[i]] {
                if hour == nil && num >= 1 && num <= 12 {
                    hour = num
                } else if hour != nil {
                    minute = num
                    break
                }
            }
        }

        if let h = hour {
            if minute > 0 {
                return "\(h):\(String(format: "%02d", minute))\(ampm.isEmpty ? "" : " \(ampm)")"
            }
            return "\(h)\(ampm.isEmpty ? "" : " \(ampm)")"
        }

        return transcript
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
