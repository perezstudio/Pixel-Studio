import Foundation
import SwiftData

@Model
final class StyleProperty {
    @Attribute(.unique) var id: UUID
    var key: CSSPropertyKey
    var customKey: String?
    var value: String
    var breakpointID: UUID?
    var sortOrder: Int = 0

    var node: Node?

    var cssKey: String {
        if key == .custom, let customKey {
            return customKey
        }
        return key.rawValue
    }

    init(key: CSSPropertyKey, value: String, breakpointID: UUID? = nil) {
        self.id = UUID()
        self.key = key
        self.value = value
        self.breakpointID = breakpointID
    }
}
