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
                }
            }
        }
    }
}
