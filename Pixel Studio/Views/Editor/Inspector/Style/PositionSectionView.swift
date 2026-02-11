import SwiftUI

/// Position section: position type, offsets, z-index.
struct PositionSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var position: String = ""
    @State private var top: String = ""
    @State private var right: String = ""
    @State private var bottom: String = ""
    @State private var left: String = ""
    @State private var zIndex: String = ""

    private var showOffsets: Bool {
        position == "relative" || position == "absolute" || position == "fixed" || position == "sticky"
    }

    var body: some View {
        CollapsibleSection("Position") {
            VStack(spacing: 6) {
                // Position type picker
                HStack(spacing: 4) {
                    Text("Position")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $position) {
                        Text("—").tag("")
                        ForEach(CSSPositionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                if showOffsets {
                    LengthInputField(label: "Top", value: $top)
                    LengthInputField(label: "Right", value: $right)
                    LengthInputField(label: "Bottom", value: $bottom)
                    LengthInputField(label: "Left", value: $left)
                }

                // Z-Index
                HStack(spacing: 4) {
                    Text("Z-Index")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("auto", text: $zIndex)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear { loadValues() }
        .onChange(of: position) { node.setStyle(key: .position, value: position.isEmpty ? nil : position, breakpointID: breakpointID) }
        .onChange(of: top) { node.setStyle(key: .top, value: top.isEmpty ? nil : top, breakpointID: breakpointID) }
        .onChange(of: right) { node.setStyle(key: .right, value: right.isEmpty ? nil : right, breakpointID: breakpointID) }
        .onChange(of: bottom) { node.setStyle(key: .bottom, value: bottom.isEmpty ? nil : bottom, breakpointID: breakpointID) }
        .onChange(of: left) { node.setStyle(key: .left, value: left.isEmpty ? nil : left, breakpointID: breakpointID) }
        .onChange(of: zIndex) { node.setStyle(key: .zIndex, value: zIndex.isEmpty ? nil : zIndex, breakpointID: breakpointID) }
    }

    private func loadValues() {
        position = node.styleValue(for: .position, breakpointID: breakpointID) ?? ""
        top = node.styleValue(for: .top, breakpointID: breakpointID) ?? ""
        right = node.styleValue(for: .right, breakpointID: breakpointID) ?? ""
        bottom = node.styleValue(for: .bottom, breakpointID: breakpointID) ?? ""
        left = node.styleValue(for: .left, breakpointID: breakpointID) ?? ""
        zIndex = node.styleValue(for: .zIndex, breakpointID: breakpointID) ?? ""
    }
}
