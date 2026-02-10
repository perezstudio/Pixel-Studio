import SwiftUI

struct NodeRowView: View {
    let node: Node
    let depth: Int
    @Environment(EditorState.self) private var editorState
    @State private var isHovered = false

    private var isSelected: Bool {
        editorState.selectedNodeID == node.id
    }

    var body: some View {
        @Bindable var state = editorState
        VStack(spacing: 0) {
            Button(action: { state.selectedNodeID = node.id }) {
                HStack(spacing: 4) {
                    Color.clear.frame(width: CGFloat(depth) * 16)

                    if node.nodeType.canHaveChildren {
                        Button(action: { node.isExpanded.toggle() }) {
                            Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                                .font(.system(size: 9))
                                .frame(width: 12)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(width: 12)
                    }

                    Image(systemName: node.nodeType.systemImage)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    Text(node.displayLabel)
                        .font(.system(size: 12))
                        .lineLimit(1)

                    Spacer()

                    if !node.isVisible {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
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
                Button("Duplicate") {}
                Button("Wrap in Div") {}
                Divider()
                Button("Delete", role: .destructive) {}
            }

            if node.isExpanded {
                ForEach(node.sortedChildren) { child in
                    NodeRowView(node: child, depth: depth + 1)
                }
            }
        }
    }
}
