import SwiftUI

/// Spacing section: margin and padding with box-model editors.
struct SpacingSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var marginTop: String = ""
    @State private var marginRight: String = ""
    @State private var marginBottom: String = ""
    @State private var marginLeft: String = ""

    @State private var paddingTop: String = ""
    @State private var paddingRight: String = ""
    @State private var paddingBottom: String = ""
    @State private var paddingLeft: String = ""

    var body: some View {
        CollapsibleSection("Spacing") {
            VStack(spacing: 12) {
                BoxSidesEditor(
                    label: "Margin",
                    top: $marginTop,
                    right: $marginRight,
                    bottom: $marginBottom,
                    left: $marginLeft
                )

                BoxSidesEditor(
                    label: "Padding",
                    top: $paddingTop,
                    right: $paddingRight,
                    bottom: $paddingBottom,
                    left: $paddingLeft
                )
            }
        }
        .onAppear { loadValues() }
        .onChange(of: marginTop) { node.setStyle(key: .marginTop, value: marginTop.isEmpty ? nil : marginTop, breakpointID: breakpointID) }
        .onChange(of: marginRight) { node.setStyle(key: .marginRight, value: marginRight.isEmpty ? nil : marginRight, breakpointID: breakpointID) }
        .onChange(of: marginBottom) { node.setStyle(key: .marginBottom, value: marginBottom.isEmpty ? nil : marginBottom, breakpointID: breakpointID) }
        .onChange(of: marginLeft) { node.setStyle(key: .marginLeft, value: marginLeft.isEmpty ? nil : marginLeft, breakpointID: breakpointID) }
        .onChange(of: paddingTop) { node.setStyle(key: .paddingTop, value: paddingTop.isEmpty ? nil : paddingTop, breakpointID: breakpointID) }
        .onChange(of: paddingRight) { node.setStyle(key: .paddingRight, value: paddingRight.isEmpty ? nil : paddingRight, breakpointID: breakpointID) }
        .onChange(of: paddingBottom) { node.setStyle(key: .paddingBottom, value: paddingBottom.isEmpty ? nil : paddingBottom, breakpointID: breakpointID) }
        .onChange(of: paddingLeft) { node.setStyle(key: .paddingLeft, value: paddingLeft.isEmpty ? nil : paddingLeft, breakpointID: breakpointID) }
    }

    private func loadValues() {
        marginTop = node.styleValue(for: .marginTop, breakpointID: breakpointID) ?? ""
        marginRight = node.styleValue(for: .marginRight, breakpointID: breakpointID) ?? ""
        marginBottom = node.styleValue(for: .marginBottom, breakpointID: breakpointID) ?? ""
        marginLeft = node.styleValue(for: .marginLeft, breakpointID: breakpointID) ?? ""
        paddingTop = node.styleValue(for: .paddingTop, breakpointID: breakpointID) ?? ""
        paddingRight = node.styleValue(for: .paddingRight, breakpointID: breakpointID) ?? ""
        paddingBottom = node.styleValue(for: .paddingBottom, breakpointID: breakpointID) ?? ""
        paddingLeft = node.styleValue(for: .paddingLeft, breakpointID: breakpointID) ?? ""
    }
}
