import SwiftUI

struct NavigatorTabView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState
    @State private var isRootDropTargeted = false

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    private var rootNodes: [Node] {
        selectedPage?.rootNodes.sorted { $0.sortOrder < $1.sortOrder } ?? []
    }

    var body: some View {
        ScrollView {
            if selectedPage != nil {
                LazyVStack(spacing: 0) {
                    ForEach(rootNodes) { node in
                        NodeRowView(node: node, depth: 0)
                    }

                    // Root-level drop zone at the bottom
                    Rectangle()
                        .fill(isRootDropTargeted ? Color.accentColor.opacity(0.15) : Color.clear)
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                        .dropDestination(for: String.self) { items, _ in
                            guard let droppedIDString = items.first,
                                  let droppedID = UUID(uuidString: droppedIDString),
                                  let page = selectedPage
                            else { return false }
                            return moveToRoot(droppedID: droppedID, page: page)
                        } isTargeted: { targeted in
                            isRootDropTargeted = targeted
                        }
                }
                .padding(.bottom, 40)
            } else {
                VStack(spacing: 8) {
                    Spacer().frame(height: 40)
                    Text("Select a page")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func moveToRoot(droppedID: UUID, page: Page) -> Bool {
        guard let droppedNode = findNode(id: droppedID, in: page.rootNodes) else { return false }
        // Already a root node? just reorder to end
        if droppedNode.page != nil {
            droppedNode.sortOrder = page.rootNodes.count
            return true
        }
        // Remove from parent
        if let oldParent = droppedNode.parent {
            oldParent.children.removeAll { $0.id == droppedID }
        }
        // Add as root
        droppedNode.parent = nil
        droppedNode.page = page
        droppedNode.sortOrder = page.rootNodes.count
        page.rootNodes.append(droppedNode)
        return true
    }

    private func findNode(id: UUID, in nodes: [Node]) -> Node? {
        for node in nodes {
            if node.id == id { return node }
            if let found = findNode(id: id, in: node.children) { return found }
        }
        return nil
    }
}
