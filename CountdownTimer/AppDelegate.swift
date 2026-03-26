import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel?
    let viewModel = CountdownViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              url.scheme == "countdown",
              let host = url.host else { return }
        handleTimeString(host)
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

    func showTimer(targetDate: Date) {
        viewModel.start(targetDate: targetDate)

        if panel == nil {
            createPanel()
        }

        positionPanel()
        panel?.orderFront(nil)
    }

    func dismissTimer() {
        viewModel.stop()
        panel?.orderOut(nil)
    }

    private func createPanel() {
        let view = CountdownView(viewModel: viewModel) { [weak self] in
            self?.dismissTimer()
        }
        panel = FloatingPanel(contentView: NSHostingView(rootView: view))
    }

    private func positionPanel() {
        guard let panel = panel, let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        let x = visibleFrame.maxX - panel.frame.width - 16
        let y = visibleFrame.maxY - panel.frame.height - 16
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func showConfirmation(message: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Confirm Timer"
            alert.informativeText = message
            alert.addButton(withTitle: "Start")
            alert.addButton(withTitle: "Cancel")
            completion(alert.runModal() == .alertFirstButtonReturn)
        }
    }

    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = message
            alert.runModal()
        }
    }
}
