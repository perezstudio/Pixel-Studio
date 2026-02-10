import Foundation

enum CSSPositionType: String, Codable, CaseIterable, Sendable {
    case `static`
    case relative
    case absolute
    case fixed
    case sticky
}
