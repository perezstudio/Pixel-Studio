import SwiftUI

struct ContentContainerView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState
    @State private var showBlockInsert = false

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    var body: some View {
        VStack(spacing: 0) {
            ContentToolbarView(
                project: project,
                showBlockInsert: $showBlockInsert
            )

            Divider()

            // Canvas area
            if let page = selectedPage {
                CanvasView(project: project, page: page)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                emptyState
            }
        }
        .background(VisualEffectBackground(material: .contentBackground, blendingMode: .withinWindow))
        .sheet(isPresented: $showBlockInsert) {
            BlockInsertSheet(project: project)
        }
    }

    private var emptyState: some View {
        ZStack {
            Color(nsColor: .controlBackgroundColor)

            VStack(spacing: 8) {
                Image(systemName: "macwindow")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
                Text("Canvas Preview")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Select a page to start building")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
