import AppIntents
import AppKit

struct CountdownIntent: AppIntent {
    static let title: LocalizedStringResource = "Saz Bunny Countdown"
    static let description = IntentDescription("Set a focus timer to a specific time")
    static let openAppWhenRun = true

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
        case .success(let date):
            appDelegate.showTimer(targetDate: date, originalInput: time)
            return .result(dialog: "Timer set to \(formatted(date))")
        case .failure(let message):
            throw SazBunnyError.invalidTime(message)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    private func formatted(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
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
