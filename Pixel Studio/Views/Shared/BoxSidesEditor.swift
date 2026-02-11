import SwiftUI

/// Visual 4-side editor for margin/padding (like Chrome DevTools box model).
/// Displays top/right/bottom/left fields with optional link for uniform values.
struct BoxSidesEditor: View {
    let label: String
    @Binding var top: String
    @Binding var right: String
    @Binding var bottom: String
    @Binding var left: String
    @State private var isLinked: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: {
                    isLinked.toggle()
                    if isLinked {
                        // Sync all to top value
                        let v = top
                        right = v
                        bottom = v
                        left = v
                    }
                }) {
                    Image(systemName: isLinked ? "link" : "link.badge.plus")
                        .font(.system(size: 10))
                        .foregroundStyle(isLinked ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
                .help(isLinked ? "Unlink sides" : "Link all sides")
            }

            // Box layout
            VStack(spacing: 2) {
                // Top
                sideField("T", value: $top)

                HStack(spacing: 8) {
                    // Left
                    sideField("L", value: $left)

                    Spacer()

                    // Right
                    sideField("R", value: $right)
                }

                // Bottom
                sideField("B", value: $bottom)
            }
        }
        .onChange(of: top) {
            if isLinked { right = top; bottom = top; left = top }
        }
    }

    private func sideField(_ label: String, value: Binding<String>) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
                .frame(width: 10)

            TextField("0", text: value)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 10))
                .frame(width: 55)
        }
        .frame(maxWidth: .infinity)
    }
}
