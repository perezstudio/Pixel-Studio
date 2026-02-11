import SwiftUI

/// Settings tab that shows context-sensitive controls based on the selected node type.
struct SettingsTabView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    private var selectedNode: Node? {
        guard let nodeID = editorState.selectedNodeID else { return nil }
        return findNode(id: nodeID)
    }

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    var body: some View {
        ScrollView {
            if let node = selectedNode {
                VStack(spacing: 0) {
                    // Node type header
                    HStack(spacing: 6) {
                        Image(systemName: node.nodeType.systemImage)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text(node.displayLabel)
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                    Divider()

                    // Context-sensitive settings
                    switch node.nodeType {
                    case .img:
                        ImageSettingsView(node: node)
                    case .a:
                        LinkSettingsView(node: node)
                    case .h1, .h2, .h3, .h4, .h5, .h6, .p, .span, .blockquote, .pre, .code, .label, .legend, .li, .option, .button, .td, .th:
                        TextSettingsView(node: node)
                    case .form:
                        FormSettingsView(node: node)
                    case .input, .textarea, .select:
                        FormElementSettingsView(node: node)
                    default:
                        GenericSettingsView(node: node)
                    }
                }
            } else if let page = selectedPage {
                PageSettingsView(page: page)
            } else {
                VStack(spacing: 8) {
                    Spacer().frame(height: 40)
                    Image(systemName: "gearshape")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text("Settings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Select an element to view settings")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }

    private func findNode(id: UUID) -> Node? {
        guard let pageID = editorState.selectedPageID else { return nil }
        guard let page = project.pages.first(where: { $0.id == pageID }) else { return nil }
        return findNodeInTree(id: id, nodes: page.rootNodes)
    }

    private func findNodeInTree(id: UUID, nodes: [Node]) -> Node? {
        for node in nodes {
            if node.id == id { return node }
            if let found = findNodeInTree(id: id, nodes: node.children) { return found }
        }
        return nil
    }
}
