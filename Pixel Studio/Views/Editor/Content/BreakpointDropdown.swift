import SwiftUI

/// Dropdown menu for selecting the active breakpoint in the canvas.
struct BreakpointDropdown: View {
    let project: Project
    @Environment(EditorState.self) private var editorState
    @State private var showEditSheet = false

    private var breakpoints: [Breakpoint] {
        project.breakpoints.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var activeBreakpoint: Breakpoint? {
        if let bpID = editorState.activeBreakpointID {
            return project.breakpoints.first { $0.id == bpID }
        }
        return project.breakpoints.first { $0.isDefault }
    }

    var body: some View {
        @Bindable var state = editorState

        Menu {
            ForEach(breakpoints) { breakpoint in
                Button(action: { state.activeBreakpointID = breakpoint.id }) {
                    HStack {
                        Text(breakpoint.name)
                        Spacer()
                        if let width = breakpoint.maxWidth ?? breakpoint.minWidth {
                            Text("\(width)px")
                                .foregroundStyle(.secondary)
                        } else if breakpoint.isDefault {
                            Text("Default")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Divider()

            Button("Edit Breakpoints...") {
                showEditSheet = true
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "rectangle.split.3x1")
                    .font(.system(size: 11))
                Text(activeBreakpoint?.name ?? "Base")
                    .font(.system(size: 12))
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.06))
            .cornerRadius(6)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .sheet(isPresented: $showEditSheet) {
            EditBreakpointsSheet(project: project)
        }
    }
}
