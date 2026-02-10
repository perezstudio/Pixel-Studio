import SwiftUI

struct ContentToolbarView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Plus button (block insert)
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("Insert Block")

            Spacer()

            // Center: page name + branch
            VStack(spacing: 1) {
                Text(selectedPage?.name ?? "No Page Selected")
                    .font(.system(size: 13, weight: .medium))

                Text("main")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Preview controls
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .font(.system(size: 12))
                Text("Run")
                    .font(.system(size: 12))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
