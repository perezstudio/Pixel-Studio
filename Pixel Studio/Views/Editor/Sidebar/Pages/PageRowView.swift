import SwiftUI
import SwiftData

struct PageRowView: View {
    let page: Page
    @Environment(EditorState.self) private var editorState
    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false

    private var isSelected: Bool {
        editorState.selectedPageID == page.id
    }

    var body: some View {
        @Bindable var state = editorState
        Button(action: { state.selectedPageID = page.id }) {
            HStack(spacing: 8) {
                Image(systemName: page.isLayout ? "rectangle.split.3x1" : "doc.text")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 1) {
                    Text(page.name)
                        .font(.system(size: 13))
                        .lineLimit(1)

                    Text(page.route)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                if page.isLayout {
                    Text("Layout")
                        .font(.system(size: 9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.15)
                    : isHovered
                        ? Color.primary.opacity(0.04)
                        : Color.clear
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .contextMenu {
            Button("Duplicate") { duplicatePage() }
            Divider()
            Button("Delete", role: .destructive) { deletePage() }
        }
    }

    private func duplicatePage() {
        let newPage = Page(
            name: "\(page.name) Copy",
            route: "\(page.route)-copy",
            slug: "\(page.slug)-copy",
            isLayout: page.isLayout
        )
        newPage.sortOrder = page.sortOrder + 1
        newPage.project = page.project
        modelContext.insert(newPage)
    }

    private func deletePage() {
        modelContext.delete(page)
        if editorState.selectedPageID == page.id {
            editorState.selectedPageID = nil
        }
    }
}
