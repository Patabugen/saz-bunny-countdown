import AppIntents
import AppKit

struct CountdownIntent: AppIntent {
    static var title: LocalizedStringResource = "Countdown Timer"
    static var description = IntentDescription("Start a countdown to a specific time")
    static var openAppWhenRun = true

    @Parameter(title: "Time", description: "Target time (e.g. 4:20, 3:30 PM)")
    var time: String

    static var parameterSummary: some ParameterSummary {
        Summary("Countdown to \(\.$time)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            throw CountdownError.appNotReady
        }

        // Delegate to app delegate which handles confirmation dialogs for night hours
        appDelegate.handleTimeString(time)

        let result = TimeParser.parse(time)
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            return .result(dialog: "Countdown to \(formatted(date))")
        case .failure(let message):
            throw CountdownError.invalidTime(message)
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    enum CountdownError: Swift.Error, CustomLocalizedStringResourceConvertible {
        case invalidTime(String)
        case appNotReady

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .invalidTime(let msg): return "\(msg)"
            case .appNotReady: return "App is not ready"
            }
        }
    }
}

struct CountdownShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CountdownIntent(),
            phrases: [
                "Start a countdown in \(.applicationName)",
                "Start \(.applicationName)",
                "\(.applicationName) countdown",
            ],
            shortTitle: "Countdown",
            systemImageName: "timer"
        )
    }
}
