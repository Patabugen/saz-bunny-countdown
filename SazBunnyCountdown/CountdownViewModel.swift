import Foundation
import AppKit
import Combine

@MainActor
class CountdownViewModel: ObservableObject {
    @Published var timeString: String = "00:00"
    @Published var targetTimeString: String?
    @Published var isFinished: Bool = false

    private var targetDate: Date?
    private var timer: AnyCancellable?

    func start(targetDate: Date) {
        stop()
        self.targetDate = targetDate
        self.isFinished = false

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        self.targetTimeString = formatter.string(from: targetDate)

        updateDisplay()

        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDisplay()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        targetDate = nil
    }

    func updateDisplay(now: Date = Date()) {
        guard let targetDate = targetDate else { return }

        let remaining = targetDate.timeIntervalSince(now)

        if remaining < 1 {
            timeString = "00:00"
            if !isFinished {
                isFinished = true
                timer?.cancel()
                timer = nil
                playSound()
            }
            return
        }

        let total = Int(remaining)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeString = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func playSound() {
        NSSound(named: "Glass")?.play()
    }
}
