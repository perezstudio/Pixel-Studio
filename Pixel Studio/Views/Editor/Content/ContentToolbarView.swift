import SwiftUI
import AppKit

struct ContentToolbarView: View {
    let project: Project
    @Binding var showBlockInsert: Bool
    @Environment(EditorState.self) private var editorState

    private var selectedPage: Page? {
        guard let pageID = editorState.selectedPageID else { return nil }
        return project.pages.first { $0.id == pageID }
    }

    var body: some View {
        @Bindable var state = editorState

        HStack(spacing: 12) {
            // Show sidebar toggle when sidebar is collapsed
            if !editorState.isSidebarVisible {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.leading")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Toggle Sidebar")
            }

            // Plus button (block insert)
            Button(action: { showBlockInsert = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("Insert Block")
            .disabled(selectedPage == nil)

            Spacer()

            // Center: page name
            VStack(spacing: 1) {
                Text(selectedPage?.name ?? "No Page Selected")
                    .font(.system(size: 13, weight: .medium))

                if selectedPage != nil {
                    Text(selectedPage?.route ?? "")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Breakpoint dropdown
            if selectedPage != nil {
                BreakpointDropdown(project: project)
            }

            // Zoom controls
            if selectedPage != nil {
                HStack(spacing: 4) {
                    Button(action: { zoomOut() }) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)

                    Text("\(Int(state.canvasZoom * 100))%")
                        .font(.system(size: 11, design: .monospaced))
                        .frame(width: 40)

                    Button(action: { zoomIn() }) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)

                    Button(action: { state.canvasZoom = 1.0 }) {
                        Image(systemName: "1.magnifyingglass")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .help("Reset Zoom")
                }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
        .background(.bar)
    }

    private func toggleSidebar() {
        guard let window = NSApp.keyWindow,
              let splitVC = window.contentViewController as? EditorSplitViewController
        else { return }
        splitVC.toggleSidebar()
    }

    private func zoomIn() {
        editorState.canvasZoom = min(editorState.canvasZoom + 0.1, 3.0)
    }

    private func zoomOut() {
        editorState.canvasZoom = max(editorState.canvasZoom - 0.1, 0.25)
    }
}
