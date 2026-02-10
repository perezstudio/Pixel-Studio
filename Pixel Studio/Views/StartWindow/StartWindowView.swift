import SwiftUI
import SwiftData

struct StartWindowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    @State private var showNewProjectSheet = false

    var body: some View {
        HStack(spacing: 0) {
            // Left column: branding + actions
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                Text("Pixel Studio")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(spacing: 12) {
                    Button(action: { showNewProjectSheet = true }) {
                        Label("Create New Project", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: importProject) {
                        Label("Import Project", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .frame(width: 200)

                Spacer()
            }
            .frame(width: 280)
            .frame(maxHeight: .infinity)
            .background(.ultraThinMaterial)

            Divider()

            // Right column: project list
            ProjectListView(projects: projects) { project in
                openWindow(value: project.id)
            }
            .frame(minWidth: 400)
        }
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet()
        }
    }

    private func importProject() {
        let panel = NSOpenPanel()
        panel.title = "Import SvelteKit Project"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            let project = Project(name: url.lastPathComponent)
            if let bookmark = try? url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            ) {
                project.bookmarkData = bookmark
            }
            modelContext.insert(project)
        }
    }
}
