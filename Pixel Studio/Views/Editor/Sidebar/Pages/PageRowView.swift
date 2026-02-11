import SwiftUI
import SwiftData

struct PageRowView: View {
    let page: Page
    @Environment(EditorState.self) private var editorState
    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false
    @State private var isRenaming = false
    @State private var renameText = ""

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
                    if isRenaming {
                        TextField("Page Name", text: $renameText, onCommit: commitRename)
                            .font(.system(size: 13))
                            .textFieldStyle(.plain)
                            .onExitCommand { cancelRename() }
                            .onAppear { renameText = page.name }
                    } else {
                        Text(page.name)
                            .font(.system(size: 13))
                            .lineLimit(1)
                    }

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
        .simultaneousGesture(
            TapGesture(count: 2).onEnded { startRename() }
        )
        .onHover { hovering in isHovered = hovering }
        .draggable(page.id.uuidString) {
            Label(page.name, systemImage: "doc.text")
                .padding(6)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
        }
        .contextMenu {
            Button("Rename") { startRename() }
            Button("Duplicate") { duplicatePage() }
            Divider()
            Button("Toggle Layout") {
                page.isLayout.toggle()
                page.updatedAt = Date()
            }
            Divider()
            Button("Delete", role: .destructive) { deletePage() }
        }
    }

    // MARK: - Rename

    private func startRename() {
        renameText = page.name
        isRenaming = true
        editorState.editingPageID = page.id
    }

    private func commitRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            page.name = trimmed
            // Update slug and route based on new name
            let newSlug = trimmed
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .filter { $0.isLetter || $0.isNumber || $0 == "-" }
            page.slug = newSlug
            page.route = newSlug.isEmpty ? "/" : "/\(newSlug)"
            page.updatedAt = Date()
        }
        isRenaming = false
        editorState.editingPageID = nil
    }

    private func cancelRename() {
        isRenaming = false
        editorState.editingPageID = nil
    }

    // MARK: - Actions

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
        if editorState.selectedPageID == page.id {
            editorState.selectedPageID = nil
            editorState.clearNodeSelection()
        }
        modelContext.delete(page)
    }
}
