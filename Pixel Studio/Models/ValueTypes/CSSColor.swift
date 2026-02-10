import Foundation

struct CSSColor: Codable, Hashable, Sendable {
    enum ColorType: String, Codable, Sendable {
        case hex
        case rgba
        case hsla
        case named
        case tokenReference
    }

    var type: ColorType
    var hex: String?
    var red: Double?
    var green: Double?
    var blue: Double?
    var alpha: Double?
    var hue: Double?
    var saturation: Double?
    var lightness: Double?
    var named: String?
    var tokenID: UUID?

    var cssString: String {
        switch type {
        case .hex:
            return hex ?? "#000000"
        case .rgba:
            let r = Int(red ?? 0)
            let g = Int(green ?? 0)
            let b = Int(blue ?? 0)
            let a = alpha ?? 1.0
            if a == 1.0 {
                return "rgb(\(r), \(g), \(b))"
            }
            return "rgba(\(r), \(g), \(b), \(a))"
        case .hsla:
            let h = Int(hue ?? 0)
            let s = Int(saturation ?? 0)
            let l = Int(lightness ?? 0)
            let a = alpha ?? 1.0
            if a == 1.0 {
                return "hsl(\(h), \(s)%, \(l)%)"
            }
            return "hsla(\(h), \(s)%, \(l)%, \(a))"
        case .named:
            return named ?? "black"
        case .tokenReference:
            if let tokenID {
                return "var(--token-\(tokenID.uuidString))"
            }
            return "inherit"
        }
    }

    static let black = CSSColor(type: .hex, hex: "#000000")
    static let white = CSSColor(type: .hex, hex: "#ffffff")
    static let transparent = CSSColor(type: .named, named: "transparent")
}
