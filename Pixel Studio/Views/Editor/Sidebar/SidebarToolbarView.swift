import SwiftUI
import AppKit

struct SidebarToolbarView: View {
    var body: some View {
        HStack {
            Button(action: toggleSidebar) {
                Image(systemName: "sidebar.leading")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("Toggle Sidebar")

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func toggleSidebar() {
        guard let window = NSApp.keyWindow,
              let splitVC = window.contentViewController as? EditorSplitViewController
        else { return }
        splitVC.toggleSidebar()
    }
}
