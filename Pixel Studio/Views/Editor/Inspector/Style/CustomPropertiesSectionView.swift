import SwiftUI

/// Custom properties section: dynamic list of arbitrary key:value CSS pairs.
struct CustomPropertiesSectionView: View {
    let node: Node
    let breakpointID: UUID?

    @State private var customProperties: [(key: String, value: String)] = []
    @State private var newKey: String = ""
    @State private var newValue: String = ""

    var body: some View {
        CollapsibleSection("Custom CSS", isExpanded: false) {
            VStack(spacing: 6) {
                // Existing custom properties
                ForEach(Array(customProperties.enumerated()), id: \.offset) { index, prop in
                    HStack(spacing: 4) {
                        TextField("property", text: Binding(
                            get: { customProperties[index].key },
                            set: { newKey in
                                let oldKey = customProperties[index].key
                                node.removeCustomStyle(customKey: oldKey, breakpointID: breakpointID)
                                customProperties[index].key = newKey
                                if !newKey.isEmpty {
                                    node.setCustomStyle(customKey: newKey, value: customProperties[index].value, breakpointID: breakpointID)
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity)

                        Text(":")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)

                        TextField("value", text: Binding(
                            get: { customProperties[index].value },
                            set: { newValue in
                                customProperties[index].value = newValue
                                let key = customProperties[index].key
                                if !key.isEmpty {
                                    node.setCustomStyle(customKey: key, value: newValue, breakpointID: breakpointID)
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity)

                        Button(action: {
                            let key = customProperties[index].key
                            node.removeCustomStyle(customKey: key, breakpointID: breakpointID)
                            customProperties.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Add new
                HStack(spacing: 4) {
                    TextField("property", text: $newKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity)

                    Text(":")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    TextField("value", text: $newValue)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity)

                    Button(action: addProperty) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(newKey.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear { loadValues() }
    }

    private func addProperty() {
        let key = newKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        node.setCustomStyle(customKey: key, value: newValue, breakpointID: breakpointID)
        customProperties.append((key: key, value: newValue))
        newKey = ""
        newValue = ""
    }

    private func loadValues() {
        customProperties = node.customStyles(breakpointID: breakpointID)
    }
}
