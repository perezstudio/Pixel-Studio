import SwiftUI

/// Main style inspector tab. Shows all 10 CSS sections when a node is selected.
struct StyleTabView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    private var selectedNode: Node? {
        guard let nodeID = editorState.selectedNodeID else { return nil }
        return findNode(id: nodeID)
    }

    var body: some View {
        if let node = selectedNode {
            VStack(spacing: 0) {
                // Node type header
                HStack(spacing: 6) {
                    Image(systemName: node.nodeType.systemImage)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text(node.displayLabel)
                        .font(.system(size: 12, weight: .medium))
                    Text("<\(node.nodeType.rawValue)>")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                ScrollView {
                    VStack(spacing: 0) {
                        TokensSectionView(node: node, project: project)
                        Divider()
                        LayoutSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        SpacingSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        SizeSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        PositionSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        TypographySectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        BackgroundSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        BorderSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        EffectsSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                        Divider()
                        CustomPropertiesSectionView(node: node, breakpointID: editorState.activeBreakpointID)
                    }
                }
            }
        } else {
            VStack(spacing: 8) {
                Spacer().frame(height: 40)
                Image(systemName: "paintbrush")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                Text("Style Inspector")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Select an element to edit styles")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding()
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
