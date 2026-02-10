import SwiftUI

struct SidebarTabBarView: View {
    @Environment(EditorState.self) private var editorState

    var body: some View {
        @Bindable var state = editorState
        HStack(spacing: 0) {
            ForEach(EditorState.SidebarTab.allCases, id: \.self) { tab in
                Button(action: { state.activeSidebarTab = tab }) {
                    VStack(spacing: 2) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 14))
                        Text(tab.displayName)
                            .font(.system(size: 9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundStyle(
                        editorState.activeSidebarTab == tab
                            ? Color.accentColor
                            : Color.secondary
                    )
                    .background(
                        editorState.activeSidebarTab == tab
                            ? Color.accentColor.opacity(0.1)
                            : Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(.bar)
    }
}
