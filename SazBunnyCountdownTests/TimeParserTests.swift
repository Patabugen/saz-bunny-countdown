import Testing
@testable import SazBunnyCountdown
import Foundation

@Suite("TimeParser")
struct TimeParserTests {

    // MARK: - Standard Formats

    @Test("Parses colon-separated time", arguments: [
        ("4:20 PM", 16, 20),
        ("4:20 AM", 4, 20),
        ("16:20", 16, 20),
        ("12:00 PM", 12, 0),
        ("12:00 AM", 0, 0),
    ])
    func standardFormats(input: String, expectedHour: Int, expectedMinute: Int) {
        let result = TimeParser.parse(input)
        guard case .success(let date) = result else {
            if case .needsConfirmation(let date, _) = result {
                let cal = Calendar.current
                #expect(cal.component(.hour, from: date) == expectedHour)
                #expect(cal.component(.minute, from: date) == expectedMinute)
                return
            }
            Issue.record("Expected success or needsConfirmation, got failure for \(input)")
            return
        }
        let cal = Calendar.current
        #expect(cal.component(.hour, from: date) == expectedHour)
        #expect(cal.component(.minute, from: date) == expectedMinute)
    }

    // MARK: - Bare Numbers

    @Test("Parses unambiguous bare 3-4 digit numbers", arguments: [
        ("1630", 16, 30),
        ("2359", 23, 59),
    ])
    func bareNumbersUnambiguous(input: String, expectedHour: Int, expectedMinute: Int) {
        let result = TimeParser.parse(input)
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            #expect(cal.component(.hour, from: date) == expectedHour)
            #expect(cal.component(.minute, from: date) == expectedMinute)
        case .failure:
            Issue.record("Expected success for \(input)")
        }
    }

    @Test("Parses ambiguous bare numbers to nearest future occurrence", arguments: [
        ("520", 5, 20),
        ("100", 1, 0),
    ])
    func bareNumbersAmbiguous(input: String, expectedHour: Int, expectedMinute: Int) {
        let result = TimeParser.parse(input)
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            let hour = cal.component(.hour, from: date)
            let minute = cal.component(.minute, from: date)
            #expect(minute == expectedMinute)
            // Ambiguous: resolves to AM or PM depending on current time
            #expect(hour == expectedHour || hour == expectedHour + 12)
            #expect(date > Date())
        case .failure:
            Issue.record("Expected success for \(input)")
        }
    }

    // MARK: - Hour Only

    @Test("Parses hour-only input")
    func hourOnly() {
        let result = TimeParser.parse("4 PM")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            #expect(cal.component(.hour, from: date) == 16)
            #expect(cal.component(.minute, from: date) == 0)
        case .failure:
            Issue.record("Expected success for '4 PM'")
        }
    }

    // MARK: - AM/PM Edge Cases

    @Test("12 AM resolves to midnight")
    func twelveAM() {
        let result = TimeParser.parse("12 AM")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            #expect(cal.component(.hour, from: date) == 0)
            #expect(cal.component(.minute, from: date) == 0)
        case .failure:
            Issue.record("Expected success for '12 AM'")
        }
    }

    @Test("12 PM resolves to noon")
    func twelvePM() {
        let result = TimeParser.parse("12 PM")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            #expect(cal.component(.hour, from: date) == 12)
            #expect(cal.component(.minute, from: date) == 0)
        case .failure:
            Issue.record("Expected success for '12 PM'")
        }
    }

    // MARK: - Result Is Always in the Future

    @Test("Parsed time is always in the future")
    func resultIsInFuture() {
        let result = TimeParser.parse("3:00 PM")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            #expect(date > Date())
        case .failure:
            Issue.record("Expected success")
        }
    }

    // MARK: - Night Hours Confirmation

    @Test("Night hours return needsConfirmation", arguments: [
        "11 PM", "11:30 PM", "3 AM", "3:00 AM",
    ])
    func nightHoursNeedConfirmation(input: String) {
        let result = TimeParser.parse(input)
        guard case .needsConfirmation = result else {
            Issue.record("Expected needsConfirmation for \(input), got \(result)")
            return
        }
    }

    @Test("Daytime hours return success", arguments: [
        "10 AM", "2 PM", "9:00 PM",
    ])
    func daytimeHoursSucceed(input: String) {
        let result = TimeParser.parse(input)
        guard case .success = result else {
            Issue.record("Expected success for \(input), got \(result)")
            return
        }
    }

    // MARK: - Invalid Inputs

    @Test("Invalid inputs return failure", arguments: [
        "abc", "", "25:00", "13:60", "99:99",
    ])
    func invalidInputs(input: String) {
        let result = TimeParser.parse(input)
        guard case .failure = result else {
            Issue.record("Expected failure for '\(input)', got \(result)")
            return
        }
    }

    // MARK: - Dot Notation AM/PM

    @Test("Parses a.m/p.m dot notation", arguments: [
        ("4:20 a.m", 4, 20),
        ("4:20 p.m", 16, 20),
        ("4:20 a.m.", 4, 20),
        ("4:20 p.m.", 16, 20),
    ])
    func dotNotationAMPM(input: String, expectedHour: Int, expectedMinute: Int) {
        let result = TimeParser.parse(input)
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            #expect(cal.component(.hour, from: date) == expectedHour)
            #expect(cal.component(.minute, from: date) == expectedMinute)
        case .failure:
            Issue.record("Expected success for '\(input)'")
        }
    }

    // MARK: - Bare Number Edge Cases

    @Test("Bare 0 resolves to midnight and needs confirmation")
    func bareZeroIsMidnight() {
        let result = TimeParser.parse("0")
        guard case .needsConfirmation(let date, _) = result else {
            Issue.record("Expected needsConfirmation for '0', got \(result)")
            return
        }
        let cal = Calendar.current
        #expect(cal.component(.hour, from: date) == 0)
        #expect(cal.component(.minute, from: date) == 0)
    }

    // MARK: - Relative "Past" / "To"

    @Test("Relative 'past' resolves to minutes past the current hour")
    func relativePast() {
        let now = Date()
        let cal = Calendar.current
        let currentMinute = cal.component(.minute, from: now)
        let result = TimeParser.parse("20 past")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let hour = cal.component(.hour, from: date)
            let minute = cal.component(.minute, from: date)
            #expect(minute == 20)
            #expect(date > now)
            // Should target the current hour if :20 hasn't passed, otherwise next hour
            let currentHour = cal.component(.hour, from: now)
            if currentMinute < 20 {
                #expect(hour == currentHour, "Expected current hour when :20 hasn't passed yet")
            } else {
                #expect(hour == (currentHour + 1) % 24, "Expected next hour when :20 has passed")
            }
        case .failure:
            Issue.record("Expected success for '20 past'")
        }
    }

    @Test("Relative 'to' resolves to minutes before the next hour")
    func relativeTo() {
        let now = Date()
        let cal = Calendar.current
        let currentMinute = cal.component(.minute, from: now)
        let result = TimeParser.parse("10 to")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let hour = cal.component(.hour, from: date)
            let minute = cal.component(.minute, from: date)
            #expect(minute == 50)
            #expect(date > now)
            // Should target the current hour if :50 hasn't passed, otherwise next hour
            let currentHour = cal.component(.hour, from: now)
            if currentMinute < 50 {
                #expect(hour == currentHour, "Expected current hour when :50 hasn't passed yet")
            } else {
                #expect(hour == (currentHour + 1) % 24, "Expected next hour when :50 has passed")
            }
        case .failure:
            Issue.record("Expected success for '10 to'")
        }
    }

    @Test("Relative 'quarter past' resolves to :15 of next hour")
    func relativeQuarterPast() {
        let result = TimeParser.parse("15 past")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            let minute = cal.component(.minute, from: date)
            #expect(minute == 15)
            #expect(date > Date())
        case .failure:
            Issue.record("Expected success for '15 past'")
        }
    }

    @Test("Relative 'quarter to' resolves to :45 of current hour")
    func relativeQuarterTo() {
        let result = TimeParser.parse("15 to")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            let cal = Calendar.current
            let minute = cal.component(.minute, from: date)
            #expect(minute == 45)
            #expect(date > Date())
        case .failure:
            Issue.record("Expected success for '15 to'")
        }
    }

    @Test("Relative time is always in the future")
    func relativeTimeIsFuture() {
        for input in ["5 past", "10 to", "20 past", "25 to", "30 past"] {
            let result = TimeParser.parse(input)
            switch result {
            case .success(let date), .needsConfirmation(let date, _):
                #expect(date > Date(), "Expected future date for '\(input)'")
            case .failure:
                Issue.record("Expected success for '\(input)'")
            }
        }
    }

    // MARK: - Ambiguous Resolution

    @Test("Ambiguous time resolves to nearest future occurrence")
    func ambiguousResolution() {
        // "4:20" with no AM/PM should resolve to whichever is nearest in the future
        let result = TimeParser.parse("4:20")
        switch result {
        case .success(let date), .needsConfirmation(let date, _):
            #expect(date > Date())
            let cal = Calendar.current
            let hour = cal.component(.hour, from: date)
            let minute = cal.component(.minute, from: date)
            // Must be either 4:20 or 16:20
            #expect((hour == 4 && minute == 20) || (hour == 16 && minute == 20))
        case .failure:
            Issue.record("Expected success for ambiguous '4:20'")
        }
    }
}
