import Foundation

enum BlockCategory: String, Codable, CaseIterable, Sendable {
    case layout
    case text
    case media
    case form
    case list
    case table
    case interactive
    case semantic

    var displayName: String {
        switch self {
        case .layout:      return "Layout"
        case .text:        return "Text"
        case .media:       return "Media"
        case .form:        return "Form"
        case .list:        return "List"
        case .table:       return "Table"
        case .interactive: return "Interactive"
        case .semantic:    return "Semantic"
        }
    }
}
