import SwiftUI
import AppKit

struct InspectorToolbarView: View {
    @Environment(EditorState.self) private var editorState

    var body: some View {
        @Bindable var state = editorState
        HStack(spacing: 0) {
            Button(action: toggleInspector) {
                Image(systemName: "sidebar.trailing")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("Toggle Inspector")

            Spacer().frame(width: 12)

            // Inspector tab bar inline
            ForEach(EditorState.InspectorTab.allCases, id: \.self) { tab in
                Button(action: { state.activeInspectorTab = tab }) {
                    Text(tab.displayName)
                        .font(.system(size: 11, weight: editorState.activeInspectorTab == tab ? .semibold : .regular))
                        .foregroundStyle(
                            editorState.activeInspectorTab == tab
                                ? Color.accentColor
                                : Color.secondary
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            editorState.activeInspectorTab == tab
                                ? Color.accentColor.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    private func toggleInspector() {
        guard let window = NSApp.keyWindow,
              let splitVC = window.contentViewController as? EditorSplitViewController
        else { return }
        splitVC.toggleInspector()
    }
}
