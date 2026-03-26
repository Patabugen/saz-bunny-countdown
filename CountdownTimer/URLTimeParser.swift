import Foundation

struct URLTimeParser {
    static func extractTime(from url: URL) -> String? {
        guard url.scheme == "countdown" else { return nil }
        guard let host = url.host else { return nil }
        var timeString = host
        if let port = url.port {
            timeString += ":\(port)"
        }
        return timeString
    }
}
