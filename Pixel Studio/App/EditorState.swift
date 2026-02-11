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

    // Clipboard (in-memory, for copy/paste of nodes)
    var clipboardNodeSnapshot: NodeSnapshot?

    // Inline editing
    var editingPageID: UUID?
    var editingNodeID: UUID?

    // MARK: - Selection helpers

    func selectNode(_ id: UUID, modifier: EventModifiers = []) {
        if modifier.contains(.command) {
            // Toggle individual selection
            if selectedNodeIDs.contains(id) {
                selectedNodeIDs.remove(id)
                if selectedNodeID == id {
                    selectedNodeID = selectedNodeIDs.first
                }
            } else {
                selectedNodeIDs.insert(id)
                selectedNodeID = id
            }
        } else {
            // Single select
            selectedNodeIDs = [id]
            selectedNodeID = id
        }
    }

    func clearNodeSelection() {
        selectedNodeID = nil
        selectedNodeIDs.removeAll()
    }

    // MARK: - Tabs

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

/// Lightweight snapshot of a node tree for clipboard operations
struct NodeSnapshot: Sendable {
    let nodeType: NodeType
    let name: String?
    let textContent: String?
    let attributes: [String: String]
    let children: [NodeSnapshot]
    let styles: [(key: CSSPropertyKey, customKey: String?, value: String, breakpointID: UUID?)]

    init(from node: Node) {
        self.nodeType = node.nodeType
        self.name = node.name
        self.textContent = node.textContent
        self.attributes = node.attributes
        self.children = node.sortedChildren.map { NodeSnapshot(from: $0) }
        self.styles = node.styles.map { ($0.key, $0.customKey, $0.value, $0.breakpointID) }
    }

    func materialize() -> Node {
        let newNode = Node(nodeType: nodeType, name: name)
        newNode.textContent = textContent
        newNode.attributes = attributes
        for styleData in styles {
            let prop = StyleProperty(key: styleData.key, value: styleData.value, breakpointID: styleData.breakpointID)
            prop.customKey = styleData.customKey
            newNode.styles.append(prop)
        }
        for (index, childSnapshot) in children.enumerated() {
            let child = childSnapshot.materialize()
            child.sortOrder = index
            child.parent = newNode
            newNode.children.append(child)
        }
        return newNode
    }
}
