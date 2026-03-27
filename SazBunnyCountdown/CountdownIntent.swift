import AppIntents
import AppKit

struct CountdownIntent: AppIntent {
    static var title: LocalizedStringResource = "Saz Bunny Countdown"
    static var description = IntentDescription("Set a focus timer to a specific time")
    static var openAppWhenRun = true

    @Parameter(title: "Time", description: "Target time (e.g. 4:20, 3:30 PM)")
    var time: String

    static var parameterSummary: some ParameterSummary {
        Summary("Timer to \(\.$time)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            throw SazBunnyError.appNotReady
        }

        let result = TimeParser.parse(time)
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            // Start the timer directly — the intent invocation acts as
            // implicit confirmation, avoiding a blocking NSAlert.runModal().
            appDelegate.showTimer(targetDate: date)
            return .result(dialog: "Timer set to \(formatted(date))")
        case .failure(let message):
            throw SazBunnyError.invalidTime(message)
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    enum SazBunnyError: Swift.Error, CustomLocalizedStringResourceConvertible {
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
                "Start a timer in \(.applicationName)",
                "Start \(.applicationName)",
                "\(.applicationName) timer",
            ],
            shortTitle: "Saz Bunny",
            systemImageName: "timer"
        )
    }
}
