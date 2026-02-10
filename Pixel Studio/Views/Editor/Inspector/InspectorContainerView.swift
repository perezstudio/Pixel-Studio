import SwiftUI

struct InspectorContainerView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    var body: some View {
        VStack(spacing: 0) {
            InspectorToolbarView()

            Divider()

            ScrollView {
                switch editorState.activeInspectorTab {
                case .style:
                    StyleTabPlaceholderView()
                case .settings:
                    SettingsTabPlaceholderView()
                case .git:
                    GitTabPlaceholderView()
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// Placeholder views for Phase 5 implementation
struct StyleTabPlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 40)
            Image(systemName: "paintbrush")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("Style Inspector")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Select an element to edit styles")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct SettingsTabPlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 40)
            Image(systemName: "gearshape")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("Settings")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Select an element to view settings")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

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
