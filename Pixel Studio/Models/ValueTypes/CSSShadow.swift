import Foundation

struct CSSShadow: Codable, Hashable, Sendable {
    var offsetX: CSSLength
    var offsetY: CSSLength
    var blurRadius: CSSLength
    var spreadRadius: CSSLength?
    var color: CSSColor
    var isInset: Bool

    var cssString: String {
        var parts: [String] = []
        if isInset {
            parts.append("inset")
        }
        parts.append(offsetX.cssString)
        parts.append(offsetY.cssString)
        parts.append(blurRadius.cssString)
        if let spread = spreadRadius {
            parts.append(spread.cssString)
        }
        parts.append(color.cssString)
        return parts.joined(separator: " ")
    }

    static let none = CSSShadow(
        offsetX: .zero,
        offsetY: .zero,
        blurRadius: .zero,
        color: .transparent,
        isInset: false
    )
}
