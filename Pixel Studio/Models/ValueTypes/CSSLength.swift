import Foundation

struct CSSLength: Codable, Hashable, Sendable {
    var value: Double
    var unit: CSSUnit

    var cssString: String {
        if unit == .auto { return "auto" }
        if unit == .none { return "" }
        if value == 0 { return "0" }
        let formatted = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%g", value)
        return "\(formatted)\(unit.rawValue)"
    }

    static let zero = CSSLength(value: 0, unit: .px)
    static let auto = CSSLength(value: 0, unit: .auto)
}
