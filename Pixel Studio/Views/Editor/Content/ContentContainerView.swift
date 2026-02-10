import SwiftUI

struct ContentContainerView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    var body: some View {
        VStack(spacing: 0) {
            ContentToolbarView(project: project)

            Divider()

            // Canvas area
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
}
