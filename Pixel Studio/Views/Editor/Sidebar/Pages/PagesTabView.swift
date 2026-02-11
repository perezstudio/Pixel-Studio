import SwiftUI

struct PagesTabView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    private var sortedPages: [Page] {
        project.pages.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sortedPages) { page in
                    PageRowView(page: page)
                        .dropDestination(for: String.self) { items, _ in
                            guard let droppedIDString = items.first,
                                  let droppedID = UUID(uuidString: droppedIDString),
                                  droppedID != page.id
                            else { return false }
                            return reorderPage(droppedID: droppedID, beforePage: page)
                        }
                }
            }
        }
    }

    private func reorderPage(droppedID: UUID, beforePage target: Page) -> Bool {
        guard let droppedPage = project.pages.first(where: { $0.id == droppedID }) else { return false }

        // Collect sorted pages, remove the dragged one, insert at target position
        var pages = sortedPages.filter { $0.id != droppedID }
        if let targetIndex = pages.firstIndex(where: { $0.id == target.id }) {
            pages.insert(droppedPage, at: targetIndex)
        } else {
            pages.append(droppedPage)
        }

        // Update sort orders
        for (index, page) in pages.enumerated() {
            page.sortOrder = index
        }
        return true
    }
}
