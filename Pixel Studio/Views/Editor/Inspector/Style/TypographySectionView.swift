import SwiftUI

/// Typography section: font family, size, weight, style, line-height, letter-spacing, text-align, decoration, transform, color.
struct TypographySectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var fontFamily: String = ""
    @State private var fontSize: String = ""
    @State private var fontWeight: String = ""
    @State private var fontStyle: String = ""
    @State private var lineHeight: String = ""
    @State private var letterSpacing: String = ""
    @State private var textAlign: String = ""
    @State private var textDecoration: String = ""
    @State private var textTransform: String = ""
    @State private var color: String = ""

    var body: some View {
        CollapsibleSection("Typography") {
            VStack(spacing: 6) {
                // Font family
                HStack(spacing: 4) {
                    Text("Family")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("inherit", text: $fontFamily)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }

                // Font size
                LengthInputField(label: "Size", value: $fontSize, units: [.px, .rem, .em, .percent, .vw])

                // Weight picker
                HStack(spacing: 4) {
                    Text("Weight")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $fontWeight) {
                        Text("—").tag("")
                        ForEach(CSSFontWeight.allCases, id: \.self) { weight in
                            Text(weight.displayName).tag(weight.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                // Font style
                HStack(spacing: 4) {
                    Text("Style")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $fontStyle) {
                        Text("—").tag("")
                        Text("normal").tag("normal")
                        Text("italic").tag("italic")
                        Text("oblique").tag("oblique")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                LengthInputField(label: "Line H", value: $lineHeight, units: [.px, .rem, .em, .none])
                LengthInputField(label: "Letter", value: $letterSpacing, units: [.px, .rem, .em])

                // Text align
                HStack(spacing: 4) {
                    Text("Align")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $textAlign) {
                        Text("—").tag("")
                        Text("left").tag("left")
                        Text("center").tag("center")
                        Text("right").tag("right")
                        Text("justify").tag("justify")
                    }
                    .pickerStyle(.segmented)
                }

                // Decoration
                HStack(spacing: 4) {
                    Text("Decor")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $textDecoration) {
                        Text("—").tag("")
                        Text("none").tag("none")
                        Text("underline").tag("underline")
                        Text("line-through").tag("line-through")
                        Text("overline").tag("overline")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                // Transform
                HStack(spacing: 4) {
                    Text("Case")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $textTransform) {
                        Text("—").tag("")
                        Text("none").tag("none")
                        Text("uppercase").tag("uppercase")
                        Text("lowercase").tag("lowercase")
                        Text("capitalize").tag("capitalize")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                // Color
                ColorPickerField(label: "Color", value: $color)
            }
        }
        .onAppear { loadValues() }
        .onChange(of: fontFamily) { node.setStyle(key: .fontFamily, value: fontFamily.isEmpty ? nil : fontFamily, breakpointID: breakpointID) }
        .onChange(of: fontSize) { node.setStyle(key: .fontSize, value: fontSize.isEmpty ? nil : fontSize, breakpointID: breakpointID) }
        .onChange(of: fontWeight) { node.setStyle(key: .fontWeight, value: fontWeight.isEmpty ? nil : fontWeight, breakpointID: breakpointID) }
        .onChange(of: fontStyle) { node.setStyle(key: .fontStyle, value: fontStyle.isEmpty ? nil : fontStyle, breakpointID: breakpointID) }
        .onChange(of: lineHeight) { node.setStyle(key: .lineHeight, value: lineHeight.isEmpty ? nil : lineHeight, breakpointID: breakpointID) }
        .onChange(of: letterSpacing) { node.setStyle(key: .letterSpacing, value: letterSpacing.isEmpty ? nil : letterSpacing, breakpointID: breakpointID) }
        .onChange(of: textAlign) { node.setStyle(key: .textAlign, value: textAlign.isEmpty ? nil : textAlign, breakpointID: breakpointID) }
        .onChange(of: textDecoration) { node.setStyle(key: .textDecoration, value: textDecoration.isEmpty ? nil : textDecoration, breakpointID: breakpointID) }
        .onChange(of: textTransform) { node.setStyle(key: .textTransform, value: textTransform.isEmpty ? nil : textTransform, breakpointID: breakpointID) }
        .onChange(of: color) { node.setStyle(key: .color, value: color.isEmpty ? nil : color, breakpointID: breakpointID) }
    }

    private func loadValues() {
        fontFamily = node.styleValue(for: .fontFamily, breakpointID: breakpointID) ?? ""
        fontSize = node.styleValue(for: .fontSize, breakpointID: breakpointID) ?? ""
        fontWeight = node.styleValue(for: .fontWeight, breakpointID: breakpointID) ?? ""
        fontStyle = node.styleValue(for: .fontStyle, breakpointID: breakpointID) ?? ""
        lineHeight = node.styleValue(for: .lineHeight, breakpointID: breakpointID) ?? ""
        letterSpacing = node.styleValue(for: .letterSpacing, breakpointID: breakpointID) ?? ""
        textAlign = node.styleValue(for: .textAlign, breakpointID: breakpointID) ?? ""
        textDecoration = node.styleValue(for: .textDecoration, breakpointID: breakpointID) ?? ""
        textTransform = node.styleValue(for: .textTransform, breakpointID: breakpointID) ?? ""
        color = node.styleValue(for: .color, breakpointID: breakpointID) ?? ""
    }
}
