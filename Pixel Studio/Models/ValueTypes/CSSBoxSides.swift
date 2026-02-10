import Foundation

struct CSSBoxSides: Codable, Hashable, Sendable {
    var top: CSSLength?
    var right: CSSLength?
    var bottom: CSSLength?
    var left: CSSLength?

    var isUniform: Bool {
        top == right && right == bottom && bottom == left
    }

    var cssShorthand: String {
        let t = top?.cssString ?? "0"
        let r = right?.cssString ?? "0"
        let b = bottom?.cssString ?? "0"
        let l = left?.cssString ?? "0"

        if t == r && r == b && b == l {
            return t
        }
        if t == b && r == l {
            return "\(t) \(r)"
        }
        if r == l {
            return "\(t) \(r) \(b)"
        }
        return "\(t) \(r) \(b) \(l)"
    }

    static let zero = CSSBoxSides(
        top: .zero, right: .zero, bottom: .zero, left: .zero
    )
}
