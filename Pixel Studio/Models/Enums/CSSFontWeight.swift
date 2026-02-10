import Foundation

enum CSSFontWeight: String, Codable, CaseIterable, Sendable {
    case thin = "100"
    case extraLight = "200"
    case light = "300"
    case normal = "400"
    case medium = "500"
    case semiBold = "600"
    case bold = "700"
    case extraBold = "800"
    case black = "900"

    var displayName: String {
        switch self {
        case .thin:       return "Thin"
        case .extraLight: return "Extra Light"
        case .light:      return "Light"
        case .normal:     return "Normal"
        case .medium:     return "Medium"
        case .semiBold:   return "Semi Bold"
        case .bold:       return "Bold"
        case .extraBold:  return "Extra Bold"
        case .black:      return "Black"
        }
    }
}
