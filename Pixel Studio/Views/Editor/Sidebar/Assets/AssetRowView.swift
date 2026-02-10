import SwiftUI
import SwiftData

struct AssetRowView: View {
    let asset: Asset
    @Environment(\.modelContext) private var modelContext
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: asset.fileType.systemImage)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(asset.name)
                    .font(.system(size: 12))
                    .lineLimit(1)

                Text(asset.fileName)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(isHovered ? Color.primary.opacity(0.04) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in isHovered = hovering }
        .contextMenu {
            Button("Delete", role: .destructive) {
                modelContext.delete(asset)
            }
        }
    }
}
