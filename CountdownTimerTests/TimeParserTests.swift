import Testing
@testable import CountdownTimer
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

    @Test("Parses bare 3-4 digit numbers", arguments: [
        ("520", 5, 20),
        ("1630", 16, 30),
        ("100", 1, 0),
        ("2359", 23, 59),
    ])
    func bareNumbers(input: String, expectedHour: Int, expectedMinute: Int) {
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
