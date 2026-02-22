import AppKit
import SwiftUI
import SwiftData

class EditorSplitViewController: NSSplitViewController {
    var project: Project!
    var editorState: EditorState!
    var appState: AppState!
    var modelContext: ModelContext!
    private var keyboardHandler: EditorKeyboardHandler?

    private var sidebarItem: NSSplitViewItem!
    private var contentItem: NSSplitViewItem!
    private var inspectorItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure split view — traditional dividers, no floating panels
        splitView.isVertical = true
        splitView.dividerStyle = .thin

        // Sidebar — plain viewController (NOT sidebarWithViewController to avoid liquid glass)
        let sidebarHost = NSHostingController(
            rootView: SidebarContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        sidebarHost.safeAreaRegions = []
        sidebarItem = NSSplitViewItem(viewController: sidebarHost)
        sidebarItem.canCollapse = true
        sidebarItem.minimumThickness = 240
        sidebarItem.maximumThickness = 400
        sidebarItem.holdingPriority = .defaultLow + 1

        // Content — plain viewController
        let contentHost = NSHostingController(
            rootView: ContentContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        contentHost.safeAreaRegions = []
        contentItem = NSSplitViewItem(viewController: contentHost)
        contentItem.minimumThickness = 400
        contentItem.holdingPriority = .defaultLow

        // Inspector — plain viewController (NOT inspectorWithViewController to avoid liquid glass)
        let inspectorHost = NSHostingController(
            rootView: InspectorContainerView(project: project)
                .environment(editorState)
                .environment(appState)
                .modelContext(modelContext)
        )
        inspectorHost.safeAreaRegions = []
        inspectorItem = NSSplitViewItem(viewController: inspectorHost)
        inspectorItem.canCollapse = true
        inspectorItem.minimumThickness = 280
        inspectorItem.maximumThickness = 400
        inspectorItem.holdingPriority = .defaultLow + 1

        addSplitViewItem(sidebarItem)
        addSplitViewItem(contentItem)
        addSplitViewItem(inspectorItem)

        // Install keyboard shortcuts
        keyboardHandler = EditorKeyboardHandler(
            project: project,
            editorState: editorState,
            modelContext: modelContext
        )
        keyboardHandler?.install()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        keyboardHandler?.uninstall()
    }

    func toggleSidebar() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            sidebarItem.animator().isCollapsed.toggle()
        } completionHandler: { [weak self] in
            guard let self else { return }
            self.editorState.isSidebarVisible = !self.sidebarItem.isCollapsed
        }
    }

    func toggleInspector() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            inspectorItem.animator().isCollapsed.toggle()
        } completionHandler: { [weak self] in
            guard let self else { return }
            self.editorState.isInspectorVisible = !self.inspectorItem.isCollapsed
        }
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
