import Testing
@testable import CountdownTimer

@Suite("SpeechTimeExtractor")
struct SpeechTimeExtractorTests {

    // MARK: - Digit Patterns

    @Test("Extracts digit time with AM/PM from speech", arguments: [
        ("set timer for 5:20 pm", "5:20 pm"),
        ("countdown to 3:45 am", "3:45 am"),
        ("until 12:00", "12:00"),
        ("at 7 pm", "7 pm"),
    ])
    func digitPatterns(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - Word Numbers

    @Test("Converts word numbers to time", arguments: [
        ("five twenty", "5:20"),
        ("three fifteen", "3:15"),
        ("seven thirty", "7:30"),
        ("eleven forty", "11:40"),
    ])
    func wordNumbers(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - Compound Words

    @Test("Handles compound minute words", arguments: [
        ("three forty five", "3:45"),
        ("five twenty one", "5:21"),
        ("two fifty nine", "2:59"),
    ])
    func compoundWords(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - AM/PM with Word Numbers

    @Test("Handles AM/PM with word numbers", arguments: [
        ("five twenty pm", "5:20 pm"),
        ("three forty five am", "3:45 am"),
    ])
    func wordNumbersWithAMPM(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - Hour Only

    @Test("Handles word hour only with AM/PM", arguments: [
        ("four pm", "4 pm"),
        ("seven am", "7 am"),
    ])
    func hourOnlyWithAMPM(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - O'Clock

    @Test("Handles o'clock with digits", arguments: [
        ("9 o'clock", "9"),
        ("9 o clock", "9"),
        ("9 oclock", "9"),
        ("at 3 o'clock", "3"),
    ])
    func oclockDigits(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    @Test("Handles o'clock with word numbers", arguments: [
        ("nine o'clock", "9"),
        ("nine o clock", "9"),
        ("three oclock", "3"),
    ])
    func oclockWords(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - Passthrough

    @Test("Returns original for unrecognized input", arguments: [
        "hello world",
        "random text",
        "",
    ])
    func passthrough(input: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == input)
    }
}
