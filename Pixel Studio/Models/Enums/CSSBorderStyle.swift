import Foundation

enum CSSBorderStyle: String, Codable, CaseIterable, Sendable {
    case none
    case solid
    case dashed
    case dotted
    case double
    case groove
    case ridge
    case inset
    case outset
}
