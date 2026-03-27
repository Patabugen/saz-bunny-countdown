import Testing
@testable import CountdownTimer
import Foundation

@Suite("URLTimeParser")
struct URLTimeParserTests {

    @Test("Extracts hour-only from URL")
    func hourOnly() {
        let url = URL(string: "saz://4")!
        #expect(URLTimeParser.extractTime(from: url) == "4")
    }

    @Test("Extracts hour:minute from URL (host+port reconstruction)")
    func hourMinute() {
        let url = URL(string: "saz://5:20")!
        #expect(URLTimeParser.extractTime(from: url) == "5:20")
    }

    @Test("Extracts 24-hour time from URL")
    func twentyFourHour() {
        let url = URL(string: "saz://16:30")!
        #expect(URLTimeParser.extractTime(from: url) == "16:30")
    }

    @Test("Returns nil for non-saz scheme")
    func wrongScheme() {
        let url = URL(string: "https://example.com")!
        #expect(URLTimeParser.extractTime(from: url) == nil)
    }

    @Test("Returns nil for saz URL with no host")
    func noHost() {
        let url = URL(string: "saz:///")!
        #expect(URLTimeParser.extractTime(from: url) == nil)
    }

    @Test("Extracts host for URL with encoded spaces (AM/PM passed to TimeParser)")
    func encodedAMPM() {
        // saz://4%20PM is parsed by URL as host="4%20PM" — port is nil
        // URLTimeParser returns the host string, TimeParser handles the rest
        let url = URL(string: "saz://4%20PM")!
        let extracted = URLTimeParser.extractTime(from: url)
        // URL treats "4%20PM" as the host, decoded to "4 PM"
        #expect(extracted != nil)
    }
}
