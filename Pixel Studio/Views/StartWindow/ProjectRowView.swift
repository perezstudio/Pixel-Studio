import SwiftUI
import SwiftData

struct ProjectRowView: View {
    let project: Project
    let onOpen: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 12) {
                // Project icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "doc.text")
                            .foregroundStyle(Color.accentColor)
                    }

                // Project info
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text("\(project.pages.count) pages")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(project.updatedAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button("Open", action: onOpen)
            Divider()
            Button("Delete", role: .destructive) {
                modelContext.delete(project)
            }
        }
    }
}
