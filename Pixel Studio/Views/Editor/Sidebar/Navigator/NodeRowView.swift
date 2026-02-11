import SwiftUI
import SwiftData

struct NodeRowView: View {
    let node: Node
    let depth: Int
    @Environment(EditorState.self) private var editorState
    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false
    @State private var isRenaming = false
    @State private var renameText = ""
    @State private var isDropTargeted = false

    private var isSelected: Bool {
        editorState.selectedNodeIDs.contains(node.id) || editorState.selectedNodeID == node.id
    }

    var body: some View {
        VStack(spacing: 0) {
            nodeRow
                .draggable(node.id.uuidString) {
                    Label(node.displayLabel, systemImage: node.nodeType.systemImage)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                }
                .dropDestination(for: String.self) { items, _ in
                    guard let droppedIDString = items.first,
                          let droppedID = UUID(uuidString: droppedIDString),
                          droppedID != node.id,
                          node.nodeType.canHaveChildren
                    else { return false }
                    return reparentNode(droppedID, into: node)
                } isTargeted: { targeted in
                    isDropTargeted = targeted
                }

            if node.isExpanded {
                ForEach(node.sortedChildren) { child in
                    NodeRowView(node: child, depth: depth + 1)
                }
            }
        }
    }

    private var nodeRow: some View {
        HStack(spacing: 4) {
            Color.clear.frame(width: CGFloat(depth) * 16)

            // Disclosure triangle
            if node.nodeType.canHaveChildren {
                Button(action: { node.isExpanded.toggle() }) {
                    Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                        .frame(width: 12)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 12)
            }

            // Icon
            Image(systemName: node.nodeType.systemImage)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 16)

            // Name (inline rename or label)
            if isRenaming {
                TextField("Name", text: $renameText, onCommit: commitRename)
                    .font(.system(size: 12))
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onExitCommand { cancelRename() }
                    .onAppear { renameText = node.name ?? node.nodeType.displayName }
            } else {
                Text(node.displayLabel)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }

            Spacer()

            // Visibility toggle
            if isHovered || !node.isVisible {
                Button(action: { node.isVisible.toggle() }) {
                    Image(systemName: node.isVisible ? "eye" : "eye.slash")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }

            // Lock toggle
            if isHovered || node.isLocked {
                Button(action: { node.isLocked.toggle() }) {
                    Image(systemName: node.isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(rowBackground)
        .contentShape(Rectangle())
        .onTapGesture {
            editorState.selectNode(node.id)
        }
        .simultaneousGesture(
            TapGesture(count: 2).onEnded { startRename() }
        )
        .onHover { hovering in isHovered = hovering }
        .contextMenu { nodeContextMenu }
    }

    private var rowBackground: some View {
        Group {
            if isDropTargeted && node.nodeType.canHaveChildren {
                Color.accentColor.opacity(0.25)
            } else if isSelected {
                Color.accentColor.opacity(0.15)
            } else if isHovered {
                Color.primary.opacity(0.04)
            } else {
                Color.clear
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var nodeContextMenu: some View {
        Button("Rename") { startRename() }

        Button("Duplicate") { duplicateNode() }

        Menu("Wrap in...") {
            Button("Div") { wrapNode(in: .div) }
            Button("Section") { wrapNode(in: .section) }
            Button("Article") { wrapNode(in: .article) }
            Button("Link") { wrapNode(in: .a) }
        }

        Divider()

        Button("Copy") { copyNode() }
        Button("Cut") { cutNode() }
        Button("Paste Inside") { pasteNode() }
            .disabled(editorState.clipboardNodeSnapshot == nil || !node.nodeType.canHaveChildren)

        Divider()

        Button("Toggle Visibility") { node.isVisible.toggle() }
        Button("Toggle Lock") { node.isLocked.toggle() }

        Divider()

        Button("Delete", role: .destructive) { deleteNode() }
    }

    // MARK: - Rename

    private func startRename() {
        renameText = node.name ?? node.nodeType.displayName
        isRenaming = true
        editorState.editingNodeID = node.id
    }

    private func commitRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        node.name = trimmed.isEmpty ? nil : trimmed
        isRenaming = false
        editorState.editingNodeID = nil
    }

    private func cancelRename() {
        isRenaming = false
        editorState.editingNodeID = nil
    }

    // MARK: - Node Operations

    private func duplicateNode() {
        let snapshot = NodeSnapshot(from: node)
        let duplicate = snapshot.materialize()
        duplicate.name = (node.name ?? node.nodeType.displayName) + " Copy"

        if let parent = node.parent {
            duplicate.sortOrder = parent.children.count
            duplicate.parent = parent
            parent.children.append(duplicate)
        } else if let page = node.page {
            duplicate.sortOrder = page.rootNodes.count
            duplicate.page = page
            page.rootNodes.append(duplicate)
        }
    }

    private func wrapNode(in wrapperType: NodeType) {
        let wrapper = Node(nodeType: wrapperType)

        if let parent = node.parent {
            wrapper.sortOrder = node.sortOrder
            wrapper.parent = parent
            parent.children.append(wrapper)

            node.parent = wrapper
            node.sortOrder = 0
            wrapper.children.append(node)

            if let index = parent.children.firstIndex(where: { $0.id == node.id && $0.parent?.id != wrapper.id }) {
                parent.children.remove(at: index)
            }
        } else if let page = node.page {
            wrapper.sortOrder = node.sortOrder
            wrapper.page = page
            page.rootNodes.append(wrapper)

            node.page = nil
            node.parent = wrapper
            node.sortOrder = 0
            wrapper.children.append(node)

            if let index = page.rootNodes.firstIndex(where: { $0.id == node.id && $0.page != nil }) {
                page.rootNodes.remove(at: index)
            }
        }

        editorState.selectNode(wrapper.id)
    }

    private func copyNode() {
        editorState.clipboardNodeSnapshot = NodeSnapshot(from: node)
    }

    private func cutNode() {
        editorState.clipboardNodeSnapshot = NodeSnapshot(from: node)
        deleteNode()
    }

    private func pasteNode() {
        guard let snapshot = editorState.clipboardNodeSnapshot,
              node.nodeType.canHaveChildren else { return }
        let newNode = snapshot.materialize()
        newNode.sortOrder = node.children.count
        newNode.parent = node
        node.children.append(newNode)
        node.isExpanded = true
        editorState.selectNode(newNode.id)
    }

    private func deleteNode() {
        if editorState.selectedNodeID == node.id {
            editorState.clearNodeSelection()
        }
        editorState.selectedNodeIDs.remove(node.id)
        modelContext.delete(node)
    }

    // MARK: - Drag and Drop

    private func reparentNode(_ droppedID: UUID, into target: Node) -> Bool {
        guard let droppedNode = findNode(id: droppedID) else { return false }
        // Prevent dropping a parent into its own child
        if isDescendant(of: droppedNode, node: target) { return false }

        // Remove from old parent
        if let oldParent = droppedNode.parent {
            oldParent.children.removeAll { $0.id == droppedID }
        } else if let page = droppedNode.page {
            page.rootNodes.removeAll { $0.id == droppedID }
            droppedNode.page = nil
        }

        // Add to new parent
        droppedNode.sortOrder = target.children.count
        droppedNode.parent = target
        target.children.append(droppedNode)
        target.isExpanded = true
        return true
    }

    private func findNode(id: UUID) -> Node? {
        guard let pageID = editorState.selectedPageID else { return nil }
        // Walk up to find the page from our current node
        var current: Node? = node
        while let c = current {
            if c.page != nil { break }
            current = c.parent
        }
        guard let page = current?.page ?? node.page else { return nil }
        return findNodeInTree(id: id, nodes: page.rootNodes)
    }

    private func findNodeInTree(id: UUID, nodes: [Node]) -> Node? {
        for n in nodes {
            if n.id == id { return n }
            if let found = findNodeInTree(id: id, nodes: n.children) { return found }
        }
        return nil
    }

    private func isDescendant(of ancestor: Node, node target: Node) -> Bool {
        var current: Node? = target
        while let c = current {
            if c.id == ancestor.id { return true }
            current = c.parent
        }
        return false
    }
}
