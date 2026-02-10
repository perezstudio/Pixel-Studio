import Foundation

enum CSSFlexDirection: String, Codable, CaseIterable, Sendable {
    case row
    case rowReverse = "row-reverse"
    case column
    case columnReverse = "column-reverse"
}

enum CSSFlexWrap: String, Codable, CaseIterable, Sendable {
    case nowrap
    case wrap
    case wrapReverse = "wrap-reverse"
}

enum CSSAlignItems: String, Codable, CaseIterable, Sendable {
    case stretch
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
    case center
    case baseline
}

enum CSSJustifyContent: String, Codable, CaseIterable, Sendable {
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
    case center
    case spaceBetween = "space-between"
    case spaceAround = "space-around"
    case spaceEvenly = "space-evenly"
}

enum CSSAlignContent: String, Codable, CaseIterable, Sendable {
    case stretch
    case flexStart = "flex-start"
    case flexEnd = "flex-end"
    case center
    case spaceBetween = "space-between"
    case spaceAround = "space-around"
}
