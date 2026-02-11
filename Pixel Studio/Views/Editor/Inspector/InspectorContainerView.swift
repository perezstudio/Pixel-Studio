import SwiftUI

struct InspectorContainerView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    var body: some View {
        VStack(spacing: 0) {
            InspectorToolbarView()

            Divider()

            switch editorState.activeInspectorTab {
            case .style:
                StyleTabView(project: project)
            case .settings:
                SettingsTabView(project: project)
            case .git:
                GitTabPlaceholderView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// Git tab placeholder — will be implemented in Phase 6
struct GitTabPlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 40)
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("Git")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Generate project to enable Git")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
