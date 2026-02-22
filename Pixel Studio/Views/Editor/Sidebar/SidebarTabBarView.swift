import SwiftUI

struct SidebarTabBarView: View {
    @Environment(EditorState.self) private var editorState
    @State private var hoveredTab: EditorState.SidebarTab?

    var body: some View {
        @Bindable var state = editorState
        HStack(spacing: 4) {
            ForEach(EditorState.SidebarTab.allCases, id: \.self) { tab in
                let isSelected = editorState.activeSidebarTab == tab
                let isHovered = hoveredTab == tab

                Button(action: { state.activeSidebarTab = tab }) {
                    Image(systemName: tab.systemImage)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            isSelected ? Color.accentColor : Color.secondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .background(
                            isSelected
                                ? Color.accentColor.opacity(0.1)
                                : isHovered
                                    ? Color.secondary.opacity(0.1)
                                    : Color.clear
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help(tab.displayName)
                .onHover { hovering in
                    hoveredTab = hovering ? tab : nil
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
