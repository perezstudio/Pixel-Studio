import AppKit
import SwiftUI
import SwiftData

class EditorSplitViewController: NSSplitViewController {
    var project: Project!
    var editorState: EditorState!
    var appState: AppState!
    var modelContext: ModelContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        splitView.isVertical = true
        splitView.dividerStyle = .thin

        // Sidebar
        let sidebarHost = NSHostingController(
            rootView: SidebarContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarHost)
        sidebarItem.canCollapse = true
        sidebarItem.minimumThickness = 240
        sidebarItem.maximumThickness = 400
        sidebarItem.preferredThicknessFraction = 0.2

        // Content
        let contentHost = NSHostingController(
            rootView: ContentContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        let contentItem = NSSplitViewItem(viewController: contentHost)
        contentItem.minimumThickness = 400

        // Inspector
        let inspectorHost = NSHostingController(
            rootView: InspectorContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        let inspectorItem = NSSplitViewItem(inspectorWithViewController: inspectorHost)
        inspectorItem.canCollapse = true
        inspectorItem.minimumThickness = 280
        inspectorItem.maximumThickness = 400
        inspectorItem.preferredThicknessFraction = 0.22

        addSplitViewItem(sidebarItem)
        addSplitViewItem(contentItem)
        addSplitViewItem(inspectorItem)
    }

    func toggleSidebar() {
        guard let item = splitViewItems.first else { return }
        item.animator().isCollapsed.toggle()
    }

    func toggleInspector() {
        guard let item = splitViewItems.last else { return }
        item.animator().isCollapsed.toggle()
    }
}

struct EditorSplitViewRepresentable: NSViewControllerRepresentable {
    let project: Project
    let modelContext: ModelContext
    let appState: AppState
    let editorState: EditorState

    func makeNSViewController(context: Context) -> EditorSplitViewController {
        let vc = EditorSplitViewController()
        vc.project = project
        vc.modelContext = modelContext
        vc.appState = appState
        vc.editorState = editorState
        return vc
    }

    func updateNSViewController(_ nsViewController: EditorSplitViewController, context: Context) {
    }
}
