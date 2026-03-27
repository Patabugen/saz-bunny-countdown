import Testing
@testable import SazBunnyCountdown

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

    // MARK: - Noisy Transcripts

    @Test("Extracts time from noisy speech transcripts", arguments: [
        ("um set timer for 5:20 pm", "5:20 pm"),
        ("uh countdown to like 3:45 am please", "3:45 am"),
        ("okay so five twenty I think", "5:20"),
        ("yeah three forty five sounds good", "3:45"),
    ])
    func noisyTranscripts(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    // MARK: - Relative "Past" / "To"

    @Test("Extracts relative past/to with word numbers", arguments: [
        ("twenty past", "20 past"),
        ("ten to", "10 to"),
        ("quarter past", "15 past"),
        ("quarter to", "15 to"),
        ("half past", "30 past"),
        ("five past", "5 past"),
        ("five to", "5 to"),
        ("twenty five to", "25 to"),
    ])
    func relativePastToWords(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    @Test("Extracts relative past/to with digits", arguments: [
        ("20 past", "20 past"),
        ("10 to", "10 to"),
        ("5 past", "5 past"),
    ])
    func relativePastToDigits(input: String, expected: String) {
        #expect(SpeechTimeExtractor.extractTime(from: input) == expected)
    }

    @Test("Extracts relative past/to from noisy speech", arguments: [
        ("um twenty past", "20 past"),
        ("set timer for ten to", "10 to"),
        ("uh quarter past please", "15 past"),
    ])
    func relativePastToNoisy(input: String, expected: String) {
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
