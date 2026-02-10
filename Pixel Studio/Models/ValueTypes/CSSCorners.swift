import Foundation

struct CSSCorners: Codable, Hashable, Sendable {
    var topLeft: CSSLength?
    var topRight: CSSLength?
    var bottomRight: CSSLength?
    var bottomLeft: CSSLength?

    var isUniform: Bool {
        topLeft == topRight && topRight == bottomRight && bottomRight == bottomLeft
    }

    var cssShorthand: String {
        let tl = topLeft?.cssString ?? "0"
        let tr = topRight?.cssString ?? "0"
        let br = bottomRight?.cssString ?? "0"
        let bl = bottomLeft?.cssString ?? "0"

        if tl == tr && tr == br && br == bl {
            return tl
        }
        if tl == br && tr == bl {
            return "\(tl) \(tr)"
        }
        if tr == bl {
            return "\(tl) \(tr) \(br)"
        }
        return "\(tl) \(tr) \(br) \(bl)"
    }

    static let zero = CSSCorners(
        topLeft: .zero, topRight: .zero, bottomRight: .zero, bottomLeft: .zero
    )
}
