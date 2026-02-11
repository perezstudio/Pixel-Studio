import SwiftUI

/// Canvas view that displays the web preview at the current breakpoint dimensions.
/// Provides zoom controls and a centered, Figma-style artboard appearance.
struct CanvasView: View {
    let project: Project
    let page: Page
    @Environment(EditorState.self) private var editorState
    @State private var coordinator = PreviewCoordinator()

    private var breakpoints: [Breakpoint] {
        project.breakpoints.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var activeBreakpoint: Breakpoint? {
        if let bpID = editorState.activeBreakpointID {
            return project.breakpoints.first { $0.id == bpID }
        }
        return project.breakpoints.first { $0.isDefault }
    }

    private var canvasWidth: CGFloat {
        if let bp = activeBreakpoint {
            if let maxWidth = bp.maxWidth {
                return CGFloat(maxWidth)
            } else if let minWidth = bp.minWidth {
                return CGFloat(minWidth)
            }
        }
        return 1280
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // Neutral canvas background
                    Color(nsColor: .windowBackgroundColor)
                        .opacity(0.5)

                    // Artboard
                    VStack(spacing: 0) {
                        // Breakpoint label
                        HStack {
                            Text(activeBreakpoint?.name ?? "Base")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Text("\(Int(canvasWidth))px")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.bottom, 8)

                        // Preview container with shadow
                        WebPreviewView(
                            coordinator_: coordinator,
                            editorState: editorState,
                            onNodeSelected: { nodeID in
                                editorState.selectNode(nodeID)
                            }
                        )
                        .frame(width: canvasWidth, height: max(geometry.size.height - 80, 600))
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    .scaleEffect(editorState.canvasZoom)
                    .padding(40)
                }
                .frame(
                    minWidth: max(geometry.size.width, canvasWidth * editorState.canvasZoom + 80),
                    minHeight: max(geometry.size.height, 600)
                )
            }
        }
        .onAppear {
            coordinator.start()
            regeneratePreview()
        }
        .onDisappear {
            coordinator.stop()
        }
        .onChange(of: page.rootNodes.count) {
            regeneratePreview()
        }
        .onChange(of: editorState.activeBreakpointID) {
            regeneratePreview()
        }
    }

    private func regeneratePreview() {
        coordinator.regenerate(
            page: page,
            breakpoints: breakpoints,
            tokens: project.designTokens
        )
    }
}
