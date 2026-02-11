import SwiftUI
import SwiftData

/// Section for applying/removing design tokens to a node.
struct TokensSectionView: View {
    let node: Node
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showTokenPicker = false

    var body: some View {
        CollapsibleSection("Design Tokens") {
            VStack(alignment: .leading, spacing: 6) {
                // Applied tokens as pills
                if !node.appliedTokens.isEmpty {
                    FlowLayout(spacing: 4) {
                        ForEach(node.appliedTokens) { token in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(tokenColor(for: token.category))
                                    .frame(width: 6, height: 6)
                                Text(token.name)
                                    .font(.system(size: 10))
                                Button(action: { removeToken(token) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(10)
                        }
                    }
                }

                // Add token button
                Button(action: { showTokenPicker = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 10))
                        Text("Apply Token")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showTokenPicker) {
                    tokenPickerPopover
                }
            }
        }
    }

    private var tokenPickerPopover: some View {
        VStack(spacing: 8) {
            Text("Select Token")
                .font(.system(size: 12, weight: .medium))

            if project.designTokens.isEmpty {
                Text("No tokens defined")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(project.designTokens.sorted(by: { $0.sortOrder < $1.sortOrder })) { token in
                            Button(action: { applyToken(token) }) {
                                HStack {
                                    Circle()
                                        .fill(tokenColor(for: token.category))
                                        .frame(width: 8, height: 8)
                                    Text(token.name)
                                        .font(.system(size: 11))
                                    Spacer()
                                    Text(token.value)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(12)
        .frame(width: 220)
    }

    private func applyToken(_ token: DesignToken) {
        if !node.appliedTokens.contains(where: { $0.id == token.id }) {
            node.appliedTokens.append(token)
        }
        showTokenPicker = false
    }

    private func removeToken(_ token: DesignToken) {
        node.appliedTokens.removeAll { $0.id == token.id }
    }

    private func tokenColor(for category: TokenCategory) -> Color {
        switch category {
        case .color:      return .blue
        case .spacing:    return .green
        case .typography: return .purple
        case .sizing:     return .orange
        case .border:     return .cyan
        case .shadow:     return .gray
        case .opacity:    return .yellow
        case .custom:     return .pink
        }
    }
}

/// Simple flow layout for token pills.
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
