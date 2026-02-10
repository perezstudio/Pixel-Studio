import Foundation

struct CSSTransition: Codable, Hashable, Sendable {
    var property: String
    var duration: String
    var timingFunction: String
    var delay: String?

    var cssString: String {
        var parts = [property, duration, timingFunction]
        if let delay {
            parts.append(delay)
        }
        return parts.joined(separator: " ")
    }

    static let allEase = CSSTransition(
        property: "all",
        duration: "0.3s",
        timingFunction: "ease"
    )
}
