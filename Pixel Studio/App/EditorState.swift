import SwiftUI

@Observable
final class EditorState {
    // Selection
    var selectedPageID: UUID?
    var selectedNodeID: UUID?
    var selectedNodeIDs: Set<UUID> = []

    // Sidebar
    var isSidebarVisible: Bool = true
    var activeSidebarTab: SidebarTab = .pages

    // Inspector
    var isInspectorVisible: Bool = true
    var activeInspectorTab: InspectorTab = .style

    // Canvas
    var activeBreakpointID: UUID?
    var canvasZoom: Double = 1.0

    enum SidebarTab: String, CaseIterable, Sendable {
        case pages
        case navigator
        case assets
        case components

        var displayName: String {
            switch self {
            case .pages:      return "Pages"
            case .navigator:  return "Navigator"
            case .assets:     return "Assets"
            case .components: return "Components"
            }
        }

        var systemImage: String {
            switch self {
            case .pages:      return "doc.text"
            case .navigator:  return "list.bullet.indent"
            case .assets:     return "photo.on.rectangle"
            case .components: return "square.stack.3d.up"
            }
        }
    }

    enum InspectorTab: String, CaseIterable, Sendable {
        case style
        case settings
        case git

        var displayName: String {
            switch self {
            case .style:    return "Style"
            case .settings: return "Settings"
            case .git:      return "Git"
            }
        }

        var systemImage: String {
            switch self {
            case .style:    return "paintbrush"
            case .settings: return "gearshape"
            case .git:      return "arrow.triangle.branch"
            }
        }
    }
}
