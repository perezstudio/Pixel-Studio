import Foundation
import SwiftData

enum TokenCategory: String, Codable, CaseIterable, Sendable {
    case color
    case spacing
    case typography
    case sizing
    case border
    case shadow
    case opacity
    case custom

    var displayName: String {
        switch self {
        case .color:      return "Color"
        case .spacing:    return "Spacing"
        case .typography: return "Typography"
        case .sizing:     return "Sizing"
        case .border:     return "Border"
        case .shadow:     return "Shadow"
        case .opacity:    return "Opacity"
        case .custom:     return "Custom"
        }
    }
}

@Model
final class DesignToken {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: TokenCategory
    var value: String
    var sortOrder: Int = 0

    var project: Project?

    @Relationship
    var appliedNodes: [Node] = []

    var cssVariableName: String {
        "--\(name)"
    }

    init(name: String, category: TokenCategory, value: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.value = value
    }
}
