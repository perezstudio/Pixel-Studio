import SwiftUI
import AppKit

struct SidebarToolbarView: View {
    var body: some View {
        HStack {
            Spacer()

            Button(action: toggleSidebar) {
                Image(systemName: "sidebar.leading")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help("Toggle Sidebar")
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    private func toggleSidebar() {
        guard let window = NSApp.keyWindow,
              let splitVC = window.contentViewController as? EditorSplitViewController
        else { return }
        splitVC.toggleSidebar()
    }
}
