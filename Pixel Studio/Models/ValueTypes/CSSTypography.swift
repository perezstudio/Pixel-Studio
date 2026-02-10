import Foundation

struct CSSTypography: Codable, Hashable, Sendable {
    var fontFamily: String?
    var fontSize: CSSLength?
    var fontWeight: CSSFontWeight?
    var fontStyle: String?
    var lineHeight: CSSLength?
    var letterSpacing: CSSLength?
    var textAlign: String?
    var textDecoration: String?
    var textTransform: String?
    var color: CSSColor?

    var cssProperties: [(key: String, value: String)] {
        var props: [(String, String)] = []
        if let fontFamily {
            props.append(("font-family", fontFamily))
        }
        if let fontSize {
            props.append(("font-size", fontSize.cssString))
        }
        if let fontWeight {
            props.append(("font-weight", fontWeight.rawValue))
        }
        if let fontStyle {
            props.append(("font-style", fontStyle))
        }
        if let lineHeight {
            props.append(("line-height", lineHeight.cssString))
        }
        if let letterSpacing {
            props.append(("letter-spacing", letterSpacing.cssString))
        }
        if let textAlign {
            props.append(("text-align", textAlign))
        }
        if let textDecoration {
            props.append(("text-decoration", textDecoration))
        }
        if let textTransform {
            props.append(("text-transform", textTransform))
        }
        if let color {
            props.append(("color", color.cssString))
        }
        return props
    }
}
