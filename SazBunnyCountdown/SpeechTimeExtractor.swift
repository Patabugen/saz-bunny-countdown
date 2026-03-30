import Foundation

struct SpeechTimeExtractor {
    private static let wordNumbers: [String: Int] = [
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
        "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14,
        "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18,
        "nineteen": 19, "twenty": 20, "thirty": 30, "forty": 40,
        "fifty": 50,
    ]

    private static let relativeOnlyWords: [String: Int] = [
        "quarter": 15, "half": 30, "twenty five": 25,
    ]

    private static let compound: [String: Int] = [
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

    static func extractTime(from transcript: String) -> String {
        let lower = transcript.lowercased()

        // Match relative "X past" / "X to" patterns (e.g. "twenty past", "quarter to", "10 to")
        let relativeWords = wordNumbers.filter { $0.value <= 30 }
            .merging(relativeOnlyWords) { _, new in new }
        for (word, num) in relativeWords.sorted(by: { $0.key.count > $1.key.count }) {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\s+(past|to)\\b"
            if let range = lower.range(of: pattern, options: .regularExpression) {
                let matched = String(lower[range])
                let direction = matched.hasSuffix("to") ? "to" : "past"
                return "\(num) \(direction)"
            }
        }
        // Also match digit forms: "20 past", "10 to"
        let digitRelPattern = #"\b(\d{1,2})\s+(past|to)\b"#
        if let range = lower.range(of: digitRelPattern, options: .regularExpression) {
            return String(lower[range])
        }

        // Match "9 o'clock", "9 oclock", "9 o clock"
        let oclockPattern = #"(\d{1,2})\s*o['']?\s*clock"#
        if let match = lower.range(of: oclockPattern, options: .regularExpression) {
            let matched = String(lower[match])
            if let num = matched.split(whereSeparator: { !$0.isNumber }).first, let h = Int(num) {
                return "\(h)"
            }
        }

        let digitPattern = #"(\d{1,2}:\d{2}\s*(?:am|pm|a\.m|p\.m)?|\d{1,2}\s*(?:am|pm|a\.m|p\.m))"#
        if let range = lower.range(of: digitPattern, options: .regularExpression) {
            return String(lower[range])
        }

        // Strip o'clock variants before word parsing
        let cleaned = lower
            .replacingOccurrences(of: #"o['']?\s*clock"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        let words = cleaned.components(separatedBy: .whitespaces)
        var hour: Int?
        var minute: Int = 0
        var ampm = ""

        if lower.contains(" am") || lower.contains(" a.m") { ampm = "am" }
        if lower.contains(" pm") || lower.contains(" p.m") { ampm = "pm" }

        for i in 0..<words.count {
            if hour != nil && i + 1 < words.count {
                let twoWord = "\(words[i]) \(words[i + 1])"
                if let m = Self.compound[twoWord] {
                    minute = m
                    break
                }
            }

            if let num = Self.wordNumbers[words[i]] {
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
}
