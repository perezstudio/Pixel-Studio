import SwiftUI

struct BlockInsertSheet: View {
    let project: Project
    @Environment(EditorState.self) private var editorState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredTypes: [NodeType] {
        if searchText.isEmpty {
            return NodeType.allCases
        }
        return NodeType.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedTypes: [(BlockCategory, [NodeType])] {
        let grouped = Dictionary(grouping: filteredTypes, by: \.category)
        return BlockCategory.allCases.compactMap { category in
            guard let types = grouped[category], !types.isEmpty else { return nil }
            return (category, types)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Insert Block")
                .font(.title3)
                .fontWeight(.semibold)

            TextField("Search blocks...", text: $searchText)
                .textFieldStyle(.roundedBorder)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(groupedTypes, id: \.0) { category, types in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 4) {
                                ForEach(types, id: \.self) { nodeType in
                                    Button(action: { insertBlock(nodeType) }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: nodeType.systemImage)
                                                .font(.system(size: 16))
                                            Text(nodeType.displayName)
                                                .font(.system(size: 10))
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.primary.opacity(0.04))
                                        .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 300)

            Button("Cancel") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding(20)
        .frame(width: 340)
    }

    private func insertBlock(_ nodeType: NodeType) {
        let newNode = Node(nodeType: nodeType)

        if let selectedNodeID = editorState.selectedNodeID,
           let selectedPage = findSelectedPage() {
            // Find the selected node and add as child
            if let parentNode = findNode(id: selectedNodeID, in: selectedPage.rootNodes) {
                if parentNode.nodeType.canHaveChildren {
                    newNode.sortOrder = parentNode.children.count
                    newNode.parent = parentNode
                    parentNode.children.append(newNode)
                } else {
                    // Add as sibling
                    newNode.sortOrder = selectedPage.rootNodes.count
                    newNode.page = selectedPage
                    selectedPage.rootNodes.append(newNode)
                }
            }
        } else if let selectedPage = findSelectedPage() {
            newNode.sortOrder = selectedPage.rootNodes.count
            newNode.page = selectedPage
            selectedPage.rootNodes.append(newNode)
        }

        editorState.selectedNodeID = newNode.id
        dismiss()
    }

    private func findSelectedPage() -> Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    private func findNode(id: UUID, in nodes: [Node]) -> Node? {
        for node in nodes {
            if node.id == id { return node }
            if let found = findNode(id: id, in: node.children) {
                return found
            }
        }
        return nil
    }
}
