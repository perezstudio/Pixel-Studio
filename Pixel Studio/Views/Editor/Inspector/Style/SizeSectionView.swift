import SwiftUI

/// Size section: width, height, min/max dimensions.
struct SizeSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var width: String = ""
    @State private var height: String = ""
    @State private var minWidth: String = ""
    @State private var minHeight: String = ""
    @State private var maxWidth: String = ""
    @State private var maxHeight: String = ""

    var body: some View {
        CollapsibleSection("Size") {
            VStack(spacing: 6) {
                LengthInputField(label: "Width", value: $width)
                LengthInputField(label: "Height", value: $height)
                LengthInputField(label: "Min W", value: $minWidth)
                LengthInputField(label: "Min H", value: $minHeight)
                LengthInputField(label: "Max W", value: $maxWidth)
                LengthInputField(label: "Max H", value: $maxHeight)
            }
        }
        .onAppear { loadValues() }
        .onChange(of: width) { node.setStyle(key: .width, value: width.isEmpty ? nil : width, breakpointID: breakpointID) }
        .onChange(of: height) { node.setStyle(key: .height, value: height.isEmpty ? nil : height, breakpointID: breakpointID) }
        .onChange(of: minWidth) { node.setStyle(key: .minWidth, value: minWidth.isEmpty ? nil : minWidth, breakpointID: breakpointID) }
        .onChange(of: minHeight) { node.setStyle(key: .minHeight, value: minHeight.isEmpty ? nil : minHeight, breakpointID: breakpointID) }
        .onChange(of: maxWidth) { node.setStyle(key: .maxWidth, value: maxWidth.isEmpty ? nil : maxWidth, breakpointID: breakpointID) }
        .onChange(of: maxHeight) { node.setStyle(key: .maxHeight, value: maxHeight.isEmpty ? nil : maxHeight, breakpointID: breakpointID) }
    }

    private func loadValues() {
        width = node.styleValue(for: .width, breakpointID: breakpointID) ?? ""
        height = node.styleValue(for: .height, breakpointID: breakpointID) ?? ""
        minWidth = node.styleValue(for: .minWidth, breakpointID: breakpointID) ?? ""
        minHeight = node.styleValue(for: .minHeight, breakpointID: breakpointID) ?? ""
        maxWidth = node.styleValue(for: .maxWidth, breakpointID: breakpointID) ?? ""
        maxHeight = node.styleValue(for: .maxHeight, breakpointID: breakpointID) ?? ""
    }
}
