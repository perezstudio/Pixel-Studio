import SwiftUI

/// Displays git diff output with syntax highlighting (green additions, red deletions).
struct GitDiffView: View {
    let diffText: String

    var body: some View {
        if diffText.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text("No changes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        } else {
            ScrollView(.vertical) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(parsedLines.enumerated()), id: \.offset) { _, line in
                            diffLineView(line)
                        }
                    }
                    .padding(8)
                }
            }
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Parsing

    private struct DiffLine {
        enum Kind {
            case addition
            case deletion
            case header
            case hunkHeader
            case context
        }

        let text: String
        let kind: Kind
    }

    private var parsedLines: [DiffLine] {
        diffText.components(separatedBy: "\n").map { line in
            if line.hasPrefix("+++") || line.hasPrefix("---") {
                return DiffLine(text: line, kind: .header)
            } else if line.hasPrefix("@@") {
                return DiffLine(text: line, kind: .hunkHeader)
            } else if line.hasPrefix("+") {
                return DiffLine(text: line, kind: .addition)
            } else if line.hasPrefix("-") {
                return DiffLine(text: line, kind: .deletion)
            } else if line.hasPrefix("diff ") || line.hasPrefix("index ") {
                return DiffLine(text: line, kind: .header)
            } else {
                return DiffLine(text: line, kind: .context)
            }
        }
    }

    // MARK: - Views

    @ViewBuilder
    private func diffLineView(_ line: DiffLine) -> some View {
        Text(line.text)
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(foregroundColor(for: line.kind))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.vertical, 0.5)
            .background(backgroundColor(for: line.kind))
    }

    private func foregroundColor(for kind: DiffLine.Kind) -> Color {
        switch kind {
        case .addition:   return Color(nsColor: .systemGreen)
        case .deletion:   return Color(nsColor: .systemRed)
        case .header:     return .secondary
        case .hunkHeader: return Color(nsColor: .systemCyan)
        case .context:    return .primary
        }
    }

    private func backgroundColor(for kind: DiffLine.Kind) -> Color {
        switch kind {
        case .addition:   return Color.green.opacity(0.08)
        case .deletion:   return Color.red.opacity(0.08)
        case .hunkHeader: return Color.cyan.opacity(0.05)
        default:          return .clear
        }
    }
}
