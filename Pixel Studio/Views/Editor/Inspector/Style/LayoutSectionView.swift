import SwiftUI

/// Layout section: display type, flex controls, grid controls, gap.
struct LayoutSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var display: String = ""
    @State private var flexDirection: String = ""
    @State private var flexWrap: String = ""
    @State private var justifyContent: String = ""
    @State private var alignItems: String = ""
    @State private var alignContent: String = ""
    @State private var gap: String = ""

    private var isFlex: Bool {
        display == "flex" || display == "inline-flex"
    }

    private var isGrid: Bool {
        display == "grid" || display == "inline-grid"
    }

    var body: some View {
        CollapsibleSection("Layout") {
            VStack(spacing: 8) {
                // Display
                enumRow("Display", value: $display, options: CSSDisplayType.allCases.map(\.rawValue))

                // Flex controls
                if isFlex {
                    enumRow("Direction", value: $flexDirection, options: CSSFlexDirection.allCases.map(\.rawValue))
                    enumRow("Wrap", value: $flexWrap, options: CSSFlexWrap.allCases.map(\.rawValue))
                    enumRow("Justify", value: $justifyContent, options: CSSJustifyContent.allCases.map(\.rawValue))
                    enumRow("Align Items", value: $alignItems, options: CSSAlignItems.allCases.map(\.rawValue))
                    enumRow("Align Content", value: $alignContent, options: CSSAlignContent.allCases.map(\.rawValue))
                }

                // Grid controls
                if isGrid {
                    styleRow("Columns", key: .gridTemplateColumns)
                    styleRow("Rows", key: .gridTemplateRows)
                }

                // Gap (flex and grid)
                if isFlex || isGrid {
                    textRow("Gap", value: $gap)
                }
            }
        }
        .onAppear { loadValues() }
        .onChange(of: display) { node.setStyle(key: .display, value: display.isEmpty ? nil : display, breakpointID: breakpointID) }
        .onChange(of: flexDirection) { node.setStyle(key: .flexDirection, value: flexDirection.isEmpty ? nil : flexDirection, breakpointID: breakpointID) }
        .onChange(of: flexWrap) { node.setStyle(key: .flexWrap, value: flexWrap.isEmpty ? nil : flexWrap, breakpointID: breakpointID) }
        .onChange(of: justifyContent) { node.setStyle(key: .justifyContent, value: justifyContent.isEmpty ? nil : justifyContent, breakpointID: breakpointID) }
        .onChange(of: alignItems) { node.setStyle(key: .alignItems, value: alignItems.isEmpty ? nil : alignItems, breakpointID: breakpointID) }
        .onChange(of: alignContent) { node.setStyle(key: .alignContent, value: alignContent.isEmpty ? nil : alignContent, breakpointID: breakpointID) }
        .onChange(of: gap) { node.setStyle(key: .gap, value: gap.isEmpty ? nil : gap, breakpointID: breakpointID) }
    }

    private func loadValues() {
        display = node.styleValue(for: .display, breakpointID: breakpointID) ?? ""
        flexDirection = node.styleValue(for: .flexDirection, breakpointID: breakpointID) ?? ""
        flexWrap = node.styleValue(for: .flexWrap, breakpointID: breakpointID) ?? ""
        justifyContent = node.styleValue(for: .justifyContent, breakpointID: breakpointID) ?? ""
        alignItems = node.styleValue(for: .alignItems, breakpointID: breakpointID) ?? ""
        alignContent = node.styleValue(for: .alignContent, breakpointID: breakpointID) ?? ""
        gap = node.styleValue(for: .gap, breakpointID: breakpointID) ?? ""
    }

    private func enumRow(_ label: String, value: Binding<String>, options: [String]) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)

            Picker("", selection: value) {
                Text("—").tag("")
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
        }
    }

    private func textRow(_ label: String, value: Binding<String>) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)

            TextField("", text: value)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func styleRow(_ label: String, key: CSSPropertyKey) -> some View {
        let binding = Binding<String>(
            get: { node.styleValue(for: key, breakpointID: breakpointID) ?? "" },
            set: { node.setStyle(key: key, value: $0.isEmpty ? nil : $0, breakpointID: breakpointID) }
        )
        textRow(label, value: binding)
    }
}
