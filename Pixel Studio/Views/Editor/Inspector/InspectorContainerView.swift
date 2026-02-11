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
                GitTabView(project: project)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
