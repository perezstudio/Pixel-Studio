import Foundation
import SwiftData

@Model
final class Node {
    @Attribute(.unique) var id: UUID
    var nodeType: NodeType
    var name: String?
    var sortOrder: Int = 0
    var isExpanded: Bool = true
    var isVisible: Bool = true
    var isLocked: Bool = false

    var textContent: String?
    var attributes: [String: String] = [:]

    var page: Page?
    var parent: Node?

    @Relationship(deleteRule: .cascade, inverse: \Node.parent)
    var children: [Node] = []

    @Relationship(deleteRule: .cascade, inverse: \StyleProperty.node)
    var styles: [StyleProperty] = []

    @Relationship(inverse: \DesignToken.appliedNodes)
    var appliedTokens: [DesignToken] = []

    var componentID: UUID?

    var sortedChildren: [Node] {
        children.sorted { $0.sortOrder < $1.sortOrder }
    }

    var displayLabel: String {
        name ?? nodeType.displayName
    }

    init(nodeType: NodeType, name: String? = nil) {
        self.id = UUID()
        self.nodeType = nodeType
        self.name = name
    }
}
