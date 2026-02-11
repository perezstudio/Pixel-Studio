import SwiftUI

struct SidebarContainerView: View {
    let project: Project
    @Environment(EditorState.self) private var editorState

    var body: some View {
        VStack(spacing: 0) {
            SidebarToolbarView()

            SidebarTabBarView()

            SidebarHeaderView(project: project)

            Divider()

            switch editorState.activeSidebarTab {
            case .pages:
                PagesTabView(project: project)
            case .navigator:
                NavigatorTabView(project: project)
            case .assets:
                AssetsTabView(project: project)
            case .components:
                ComponentsTabView(project: project)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectBackground(material: .sidebar))
        .ignoresSafeArea(edges: .top)
    }
}
