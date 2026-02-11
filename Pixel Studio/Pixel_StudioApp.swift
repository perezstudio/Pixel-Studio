import SwiftUI
import SwiftData

@main
struct Pixel_StudioApp: App {
    let modelContainer: ModelContainer
    @State private var appState = AppState()

    init() {
        let schema = Schema([
            Project.self,
            Page.self,
            Node.self,
            StyleProperty.self,
            DesignToken.self,
            Component.self,
            Asset.self,
            Breakpoint.self,
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        Window("Pixel Studio", id: "start") {
            StartWindowView()
                .environment(appState)
        }
        .modelContainer(modelContainer)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 500)
        .windowResizability(.contentSize)

        WindowGroup("Editor", for: UUID.self) { $projectID in
            if let projectID {
                EditorHostView(projectID: projectID)
                    .environment(appState)
            }
        }
        .modelContainer(modelContainer)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1400, height: 900)
    }
}
