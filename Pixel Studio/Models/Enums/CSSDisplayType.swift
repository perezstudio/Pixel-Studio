import Foundation

enum CSSDisplayType: String, Codable, CaseIterable, Sendable {
    case block
    case inlineBlock = "inline-block"
    case inline
    case flex
    case inlineFlex = "inline-flex"
    case grid
    case inlineGrid = "inline-grid"
    case none
    case contents
}
