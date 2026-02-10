import Foundation
import SwiftData

enum CSSStrategy: String, Codable, Sendable {
    case scoped
    case global
    case tokens
}

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    var bookmarkData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Page.project)
    var pages: [Page] = []

    @Relationship(deleteRule: .cascade, inverse: \DesignToken.project)
    var designTokens: [DesignToken] = []

    @Relationship(deleteRule: .cascade, inverse: \Component.project)
    var components: [Component] = []

    @Relationship(deleteRule: .cascade, inverse: \Asset.project)
    var assets: [Asset] = []

    @Relationship(deleteRule: .cascade, inverse: \Breakpoint.project)
    var breakpoints: [Breakpoint] = []

    var gitRemoteURL: String?
    var svelteKitVersion: String = "2"
    var cssStrategy: CSSStrategy = CSSStrategy.scoped

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
