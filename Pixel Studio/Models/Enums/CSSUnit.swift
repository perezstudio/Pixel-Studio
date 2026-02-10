import Foundation

enum CSSUnit: String, Codable, CaseIterable, Sendable {
    case px
    case rem
    case em
    case percent = "%"
    case vw
    case vh
    case vmin
    case vmax
    case ch
    case ex
    case fr
    case auto = "auto"
    case none = ""

    var displayName: String {
        switch self {
        case .px:      return "px"
        case .rem:     return "rem"
        case .em:      return "em"
        case .percent: return "%"
        case .vw:      return "vw"
        case .vh:      return "vh"
        case .vmin:    return "vmin"
        case .vmax:    return "vmax"
        case .ch:      return "ch"
        case .ex:      return "ex"
        case .fr:      return "fr"
        case .auto:    return "auto"
        case .none:    return "—"
        }
    }
}
