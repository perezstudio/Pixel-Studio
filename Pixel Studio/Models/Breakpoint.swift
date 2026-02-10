import Foundation
import SwiftData

@Model
final class Breakpoint {
    @Attribute(.unique) var id: UUID
    var name: String
    var minWidth: Int?
    var maxWidth: Int?
    var sortOrder: Int = 0
    var isDefault: Bool = false

    var project: Project?

    init(name: String, minWidth: Int? = nil, maxWidth: Int? = nil, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.isDefault = isDefault
    }

    var mediaQuery: String? {
        if isDefault { return nil }
        var conditions: [String] = []
        if let min = minWidth {
            conditions.append("(min-width: \(min)px)")
        }
        if let max = maxWidth {
            conditions.append("(max-width: \(max)px)")
        }
        guard !conditions.isEmpty else { return nil }
        return "@media \(conditions.joined(separator: " and "))"
    }

    static func defaultBreakpoints() -> [Breakpoint] {
        let base = Breakpoint(name: "Base", isDefault: true)
        base.sortOrder = 0

        let mobile = Breakpoint(name: "Mobile", maxWidth: 640)
        mobile.sortOrder = 1

        let tablet = Breakpoint(name: "Tablet", minWidth: 641, maxWidth: 1024)
        tablet.sortOrder = 2

        let desktop = Breakpoint(name: "Desktop", minWidth: 1025)
        desktop.sortOrder = 3

        return [base, mobile, tablet, desktop]
    }
}
