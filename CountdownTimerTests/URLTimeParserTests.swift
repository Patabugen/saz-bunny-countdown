import Testing
@testable import CountdownTimer
import Foundation

@Suite("URLTimeParser")
struct URLTimeParserTests {

    @Test("Extracts hour-only from URL")
    func hourOnly() {
        let url = URL(string: "countdown://4")!
        #expect(URLTimeParser.extractTime(from: url) == "4")
    }

    @Test("Extracts hour:minute from URL (host+port reconstruction)")
    func hourMinute() {
        let url = URL(string: "countdown://5:20")!
        #expect(URLTimeParser.extractTime(from: url) == "5:20")
    }

    @Test("Extracts 24-hour time from URL")
    func twentyFourHour() {
        let url = URL(string: "countdown://16:30")!
        #expect(URLTimeParser.extractTime(from: url) == "16:30")
    }

    @Test("Returns nil for non-countdown scheme")
    func wrongScheme() {
        let url = URL(string: "https://example.com")!
        #expect(URLTimeParser.extractTime(from: url) == nil)
    }

    @Test("Returns nil for countdown URL with no host")
    func noHost() {
        let url = URL(string: "countdown:///")!
        #expect(URLTimeParser.extractTime(from: url) == nil)
    }
}
