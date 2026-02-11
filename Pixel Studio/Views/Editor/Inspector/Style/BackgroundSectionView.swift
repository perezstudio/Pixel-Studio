import SwiftUI

/// Background section: background color, image, size, position, repeat.
struct BackgroundSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var backgroundColor: String = ""
    @State private var backgroundImage: String = ""
    @State private var backgroundSize: String = ""
    @State private var backgroundPosition: String = ""
    @State private var backgroundRepeat: String = ""

    var body: some View {
        CollapsibleSection("Background", isExpanded: false) {
            VStack(spacing: 6) {
                ColorPickerField(label: "Color", value: $backgroundColor)

                HStack(spacing: 4) {
                    Text("Image")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("url(...)", text: $backgroundImage)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(maxWidth: .infinity)
                }

                HStack(spacing: 4) {
                    Text("Size")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $backgroundSize) {
                        Text("—").tag("")
                        Text("cover").tag("cover")
                        Text("contain").tag("contain")
                        Text("auto").tag("auto")
                        Text("100%").tag("100%")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 4) {
                    Text("Pos")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $backgroundPosition) {
                        Text("—").tag("")
                        Text("center").tag("center")
                        Text("top").tag("top")
                        Text("bottom").tag("bottom")
                        Text("left").tag("left")
                        Text("right").tag("right")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 4) {
                    Text("Repeat")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Picker("", selection: $backgroundRepeat) {
                        Text("—").tag("")
                        Text("repeat").tag("repeat")
                        Text("no-repeat").tag("no-repeat")
                        Text("repeat-x").tag("repeat-x")
                        Text("repeat-y").tag("repeat-y")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear { loadValues() }
        .onChange(of: backgroundColor) { node.setStyle(key: .backgroundColor, value: backgroundColor.isEmpty ? nil : backgroundColor, breakpointID: breakpointID) }
        .onChange(of: backgroundImage) { node.setStyle(key: .backgroundImage, value: backgroundImage.isEmpty ? nil : backgroundImage, breakpointID: breakpointID) }
        .onChange(of: backgroundSize) { node.setStyle(key: .backgroundSize, value: backgroundSize.isEmpty ? nil : backgroundSize, breakpointID: breakpointID) }
        .onChange(of: backgroundPosition) { node.setStyle(key: .backgroundPosition, value: backgroundPosition.isEmpty ? nil : backgroundPosition, breakpointID: breakpointID) }
        .onChange(of: backgroundRepeat) { node.setStyle(key: .backgroundRepeat, value: backgroundRepeat.isEmpty ? nil : backgroundRepeat, breakpointID: breakpointID) }
    }

    private func loadValues() {
        backgroundColor = node.styleValue(for: .backgroundColor, breakpointID: breakpointID) ?? ""
        backgroundImage = node.styleValue(for: .backgroundImage, breakpointID: breakpointID) ?? ""
        backgroundSize = node.styleValue(for: .backgroundSize, breakpointID: breakpointID) ?? ""
        backgroundPosition = node.styleValue(for: .backgroundPosition, breakpointID: breakpointID) ?? ""
        backgroundRepeat = node.styleValue(for: .backgroundRepeat, breakpointID: breakpointID) ?? ""
    }
}
