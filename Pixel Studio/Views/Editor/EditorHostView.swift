import SwiftUI
import SwiftData

struct EditorHostView: View {
    let projectID: UUID
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var editorState = EditorState()

    private var project: Project? {
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.id == projectID }
        )
        return try? modelContext.fetch(descriptor).first
    }

    var body: some View {
        Group {
            if let project {
                EditorSplitViewRepresentable(
                    project: project,
                    modelContext: modelContext,
                    appState: appState,
                    editorState: editorState
                )
                .ignoresSafeArea()
            } else {
                Text("Project not found")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .environment(editorState)
        .onAppear {
            if let project, let firstPage = project.pages.sorted(by: { $0.sortOrder < $1.sortOrder }).first {
                editorState.selectedPageID = firstPage.id
            }
        }
    }
}
