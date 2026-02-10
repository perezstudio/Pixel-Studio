import Foundation
import SwiftData

@Model
final class Page {
    @Attribute(.unique) var id: UUID
    var name: String
    var route: String
    var slug: String
    var isLayout: Bool = false
    var sortOrder: Int = 0
    var createdAt: Date
    var updatedAt: Date

    var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \Node.page)
    var rootNodes: [Node] = []

    var title: String?
    var metaDescription: String?

    init(name: String, route: String, slug: String, isLayout: Bool = false) {
        self.id = UUID()
        self.name = name
        self.route = route
        self.slug = slug
        self.isLayout = isLayout
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
