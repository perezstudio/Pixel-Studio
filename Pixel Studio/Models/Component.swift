import Foundation
import SwiftData

@Model
final class Component {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String = "Uncategorized"
    var createdAt: Date
    var updatedAt: Date

    var project: Project?

    @Relationship(deleteRule: .cascade)
    var rootNode: Node?

    init(name: String, category: String = "Uncategorized") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
