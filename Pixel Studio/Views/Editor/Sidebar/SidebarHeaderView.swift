import SwiftUI

struct SidebarHeaderView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState
    @State private var showAddSheet = false

    var body: some View {
        HStack {
            Text(editorState.activeSidebarTab.displayName)
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .help("Add \(editorState.activeSidebarTab.displayName)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .sheet(isPresented: $showAddSheet) {
            addSheetContent
        }
    }

    @ViewBuilder
    private var addSheetContent: some View {
        switch editorState.activeSidebarTab {
        case .pages:
            NewPageSheet(project: project)
        case .navigator:
            BlockInsertSheet(project: project)
        case .assets:
            AssetImportSheet(project: project)
        case .components:
            NewComponentSheet(project: project)
        }
    }
}
