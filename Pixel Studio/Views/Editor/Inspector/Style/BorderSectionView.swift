import SwiftUI

/// Border section: border width, style, color (per side), and border-radius.
struct BorderSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var borderWidthTop: String = ""
    @State private var borderWidthRight: String = ""
    @State private var borderWidthBottom: String = ""
    @State private var borderWidthLeft: String = ""

    @State private var borderStyle: String = ""
    @State private var borderColor: String = ""

    @State private var radiusTL: String = ""
    @State private var radiusTR: String = ""
    @State private var radiusBR: String = ""
    @State private var radiusBL: String = ""

    var body: some View {
        CollapsibleSection("Borders", isExpanded: false) {
            VStack(spacing: 8) {
                // Border width
                BoxSidesEditor(
                    label: "Width",
                    top: $borderWidthTop,
                    right: $borderWidthRight,
                    bottom: $borderWidthBottom,
                    left: $borderWidthLeft
                )

                // Border style (uniform for simplicity)
                HStack(spacing: 4) {
                    Text("Style")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $borderStyle) {
                        Text("—").tag("")
                        ForEach(CSSBorderStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                // Border color
                ColorPickerField(label: "Color", value: $borderColor)

                Divider()

                // Border radius
                BoxSidesEditor(
                    label: "Radius",
                    top: $radiusTL,
                    right: $radiusTR,
                    bottom: $radiusBR,
                    left: $radiusBL
                )
            }
        }
        .onAppear { loadValues() }
        .onChange(of: borderWidthTop) { node.setStyle(key: .borderTopWidth, value: borderWidthTop.isEmpty ? nil : borderWidthTop, breakpointID: breakpointID) }
        .onChange(of: borderWidthRight) { node.setStyle(key: .borderRightWidth, value: borderWidthRight.isEmpty ? nil : borderWidthRight, breakpointID: breakpointID) }
        .onChange(of: borderWidthBottom) { node.setStyle(key: .borderBottomWidth, value: borderWidthBottom.isEmpty ? nil : borderWidthBottom, breakpointID: breakpointID) }
        .onChange(of: borderWidthLeft) { node.setStyle(key: .borderLeftWidth, value: borderWidthLeft.isEmpty ? nil : borderWidthLeft, breakpointID: breakpointID) }
        .onChange(of: borderStyle) { applyBorderStyle() }
        .onChange(of: borderColor) { applyBorderColor() }
        .onChange(of: radiusTL) { node.setStyle(key: .borderTopLeftRadius, value: radiusTL.isEmpty ? nil : radiusTL, breakpointID: breakpointID) }
        .onChange(of: radiusTR) { node.setStyle(key: .borderTopRightRadius, value: radiusTR.isEmpty ? nil : radiusTR, breakpointID: breakpointID) }
        .onChange(of: radiusBR) { node.setStyle(key: .borderBottomRightRadius, value: radiusBR.isEmpty ? nil : radiusBR, breakpointID: breakpointID) }
        .onChange(of: radiusBL) { node.setStyle(key: .borderBottomLeftRadius, value: radiusBL.isEmpty ? nil : radiusBL, breakpointID: breakpointID) }
    }

    private func applyBorderStyle() {
        let val = borderStyle.isEmpty ? nil : borderStyle
        node.setStyle(key: .borderTopStyle, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderRightStyle, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderBottomStyle, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderLeftStyle, value: val, breakpointID: breakpointID)
    }

    private func applyBorderColor() {
        let val = borderColor.isEmpty ? nil : borderColor
        node.setStyle(key: .borderTopColor, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderRightColor, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderBottomColor, value: val, breakpointID: breakpointID)
        node.setStyle(key: .borderLeftColor, value: val, breakpointID: breakpointID)
    }

    private func loadValues() {
        borderWidthTop = node.styleValue(for: .borderTopWidth, breakpointID: breakpointID) ?? ""
        borderWidthRight = node.styleValue(for: .borderRightWidth, breakpointID: breakpointID) ?? ""
        borderWidthBottom = node.styleValue(for: .borderBottomWidth, breakpointID: breakpointID) ?? ""
        borderWidthLeft = node.styleValue(for: .borderLeftWidth, breakpointID: breakpointID) ?? ""
        borderStyle = node.styleValue(for: .borderTopStyle, breakpointID: breakpointID) ?? ""
        borderColor = node.styleValue(for: .borderTopColor, breakpointID: breakpointID) ?? ""
        radiusTL = node.styleValue(for: .borderTopLeftRadius, breakpointID: breakpointID) ?? ""
        radiusTR = node.styleValue(for: .borderTopRightRadius, breakpointID: breakpointID) ?? ""
        radiusBR = node.styleValue(for: .borderBottomRightRadius, breakpointID: breakpointID) ?? ""
        radiusBL = node.styleValue(for: .borderBottomLeftRadius, breakpointID: breakpointID) ?? ""
    }
}
