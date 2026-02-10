import SwiftUI

struct NavigatorTabView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

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
                }
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
}
