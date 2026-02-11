import SwiftUI

/// Effects section: opacity, box-shadow, text-shadow, transform, overflow, cursor.
struct EffectsSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var opacity: Double = 1.0
    @State private var boxShadow: String = ""
    @State private var textShadow: String = ""
    @State private var transformValue: String = ""
    @State private var overflow: String = ""
    @State private var cursor: String = ""

    var body: some View {
        CollapsibleSection("Effects", isExpanded: false) {
            VStack(spacing: 6) {
                // Opacity slider
                HStack(spacing: 4) {
                    Text("Opacity")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Slider(value: $opacity, in: 0...1, step: 0.01)

                    Text("\(Int(opacity * 100))%")
                        .font(.system(size: 10, design: .monospaced))
                        .frame(width: 35)
                }

                // Box shadow
                HStack(spacing: 4) {
                    Text("Shadow")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("0 2px 4px rgba(0,0,0,0.1)", text: $boxShadow)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity)
                }

                // Text shadow
                HStack(spacing: 4) {
                    Text("Txt Shd")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("1px 1px 2px #000", text: $textShadow)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity)
                }

                // Transform
                HStack(spacing: 4) {
                    Text("Transform")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("rotate(0deg)", text: $transformValue)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity)
                }

                // Overflow
                HStack(spacing: 4) {
                    Text("Overflow")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $overflow) {
                        Text("—").tag("")
                        ForEach(CSSOverflow.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                // Cursor
                HStack(spacing: 4) {
                    Text("Cursor")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $cursor) {
                        Text("—").tag("")
                        Text("default").tag("default")
                        Text("pointer").tag("pointer")
                        Text("text").tag("text")
                        Text("move").tag("move")
                        Text("not-allowed").tag("not-allowed")
                        Text("grab").tag("grab")
                        Text("crosshair").tag("crosshair")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear { loadValues() }
        .onChange(of: opacity) {
            let val = opacity < 1.0 ? String(format: "%.2f", opacity) : nil
            node.setStyle(key: .opacity, value: val, breakpointID: breakpointID)
        }
        .onChange(of: boxShadow) { node.setStyle(key: .boxShadow, value: boxShadow.isEmpty ? nil : boxShadow, breakpointID: breakpointID) }
        .onChange(of: textShadow) { node.setStyle(key: .textShadow, value: textShadow.isEmpty ? nil : textShadow, breakpointID: breakpointID) }
        .onChange(of: transformValue) { node.setStyle(key: .transform, value: transformValue.isEmpty ? nil : transformValue, breakpointID: breakpointID) }
        .onChange(of: overflow) { node.setStyle(key: .overflow, value: overflow.isEmpty ? nil : overflow, breakpointID: breakpointID) }
        .onChange(of: cursor) { node.setStyle(key: .cursor, value: cursor.isEmpty ? nil : cursor, breakpointID: breakpointID) }
    }

    private func loadValues() {
        if let opacityStr = node.styleValue(for: .opacity, breakpointID: breakpointID), let val = Double(opacityStr) {
            opacity = val
        } else {
            opacity = 1.0
        }
        boxShadow = node.styleValue(for: .boxShadow, breakpointID: breakpointID) ?? ""
        textShadow = node.styleValue(for: .textShadow, breakpointID: breakpointID) ?? ""
        transformValue = node.styleValue(for: .transform, breakpointID: breakpointID) ?? ""
        overflow = node.styleValue(for: .overflow, breakpointID: breakpointID) ?? ""
        cursor = node.styleValue(for: .cursor, breakpointID: breakpointID) ?? ""
    }
}
