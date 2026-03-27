import Foundation

enum ParseResult {
    case success(Date)
    case needsConfirmation(Date, String)
    case failure(String)
}

struct TimeParser {
    static func parse(_ input: String) -> ParseResult {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()

        // Check for relative "X past" / "X to" patterns
        if let relativeResult = parseRelative(trimmed) {
            return relativeResult
        }

        // Detect explicit AM/PM
        let hasAM = trimmed.hasSuffix("am") || trimmed.contains("a.m")
        let hasPM = trimmed.hasSuffix("pm") || trimmed.contains("p.m")
        let explicitPeriod = hasAM || hasPM

        // Strip AM/PM
        let timeOnly = trimmed
            .replacingOccurrences(of: #"[ap]\.?m\.?"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)

        // Parse hours and minutes
        var hour: Int
        var minute: Int = 0

        let parts = timeOnly.split(separator: ":").map(String.init)
        if parts.count == 2 {
            guard let h = Int(parts[0]), let m = Int(parts[1]),
                  (0...23).contains(h), (0...59).contains(m) else {
                return .failure("Invalid time format: \(input)")
            }
            hour = h
            minute = m
        } else if parts.count == 1, let num = Int(parts[0]) {
            if num >= 100 && num <= 2359 {
                // Bare 3-4 digit number: 520 -> 5:20, 1630 -> 16:30
                hour = num / 100
                minute = num % 100
                guard (0...23).contains(hour), (0...59).contains(minute) else {
                    return .failure("Invalid time format: \(input)")
                }
            } else if (0...23).contains(num) {
                hour = num
            } else {
                return .failure("Invalid time format: \(input)")
            }
        } else {
            return .failure("Invalid time format: \(input)")
        }

        // Apply AM/PM
        if explicitPeriod && hour <= 12 {
            if hasPM && hour != 12 { hour += 12 }
            if hasAM && hour == 12 { hour = 0 }
        }

        let calendar = Calendar.current
        let now = Date()

        // Unambiguous: explicit AM/PM or 24-hour format
        if explicitPeriod || hour > 12 {
            let target = nextOccurrence(hour: hour, minute: minute, after: now, calendar: calendar)
            return checkNightHours(target)
        }

        // Ambiguous: try both AM and PM, pick nearest future
        let amHour = (hour == 12) ? 0 : hour
        let pmHour = (hour == 12) ? 12 : hour + 12

        let amTarget = nextOccurrence(hour: amHour, minute: minute, after: now, calendar: calendar)
        let pmTarget = nextOccurrence(hour: pmHour, minute: minute, after: now, calendar: calendar)

        let target = amTarget < pmTarget ? amTarget : pmTarget
        return checkNightHours(target)
    }

    private static func parseRelative(_ input: String) -> ParseResult? {
        let pattern = #"^(\d{1,2})\s+(past|to)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)),
              let minuteRange = Range(match.range(at: 1), in: input),
              let dirRange = Range(match.range(at: 2), in: input),
              let minutes = Int(input[minuteRange]),
              (1...30).contains(minutes) else {
            return nil
        }

        let direction = String(input[dirRange])
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let nextWholeHour = (currentHour + 1) % 24

        var targetHour: Int
        var targetMinute: Int

        if direction == "past" {
            targetHour = nextWholeHour
            targetMinute = minutes
        } else {
            // "10 to" the next hour = currentHour:(60 - 10)
            targetHour = currentHour
            targetMinute = 60 - minutes
        }

        // Build target date
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = targetHour
        components.minute = targetMinute
        components.second = 0

        var target = calendar.date(from: components)!
        if target <= now {
            // Time already passed — advance by 1 hour
            target = calendar.date(byAdding: .hour, value: 1, to: target)!
        }

        return checkNightHours(target)
    }

    private static func nextOccurrence(hour: Int, minute: Int, after now: Date, calendar: Calendar) -> Date {
        var target = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)!
        if target <= now {
            target = calendar.date(byAdding: .day, value: 1, to: target)!
        }
        return target
    }

    private static func checkNightHours(_ target: Date) -> ParseResult {
        let hour = Calendar.current.component(.hour, from: target)
        if hour >= 22 || hour < 9 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let timeStr = formatter.string(from: target)
            return .needsConfirmation(
                target,
                "Timer set for \(timeStr) — that's outside 9 AM–10 PM. Start anyway?"
            )
        }
        return .success(target)
    }
}
