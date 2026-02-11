import SwiftUI

/// Generic settings for any element: ID, class, custom attributes.
struct GenericSettingsView: View {
    let node: Node

    @State private var elementID: String = ""
    @State private var cssClass: String = ""
    @State private var customAttributes: [(key: String, value: String)] = []
    @State private var newAttrKey: String = ""
    @State private var newAttrValue: String = ""

    /// Attributes managed by specialized views — excluded from the generic list.
    private static let managedAttributes: Set<String> = [
        "src", "alt", "href", "target", "rel", "action", "method",
        "type", "name", "placeholder", "value", "required",
        "width", "height", "loading", "id", "class"
    ]

    var body: some View {
        CollapsibleSection("Attributes") {
            VStack(spacing: 8) {
                // Element ID
                HStack(spacing: 4) {
                    Text("ID")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("element-id", text: $elementID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .onChange(of: elementID) {
                            if elementID.isEmpty { node.attributes.removeValue(forKey: "id") }
                            else { node.attributes["id"] = elementID }
                        }
                }

                // CSS Class
                HStack(spacing: 4) {
                    Text("Class")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)

                    TextField("class-name", text: $cssClass)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .onChange(of: cssClass) {
                            if cssClass.isEmpty { node.attributes.removeValue(forKey: "class") }
                            else { node.attributes["class"] = cssClass }
                        }
                }

                Divider()

                // Custom attributes
                ForEach(Array(customAttributes.enumerated()), id: \.offset) { index, attr in
                    HStack(spacing: 4) {
                        TextField("attr", text: Binding(
                            get: { customAttributes[index].key },
                            set: { newKey in
                                let oldKey = customAttributes[index].key
                                node.attributes.removeValue(forKey: oldKey)
                                customAttributes[index].key = newKey
                                if !newKey.isEmpty {
                                    node.attributes[newKey] = customAttributes[index].value
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))

                        Text("=")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)

                        TextField("value", text: Binding(
                            get: { customAttributes[index].value },
                            set: { newValue in
                                customAttributes[index].value = newValue
                                let key = customAttributes[index].key
                                if !key.isEmpty {
                                    node.attributes[key] = newValue
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))

                        Button(action: {
                            let key = customAttributes[index].key
                            node.attributes.removeValue(forKey: key)
                            customAttributes.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Add new attribute
                HStack(spacing: 4) {
                    TextField("attr", text: $newAttrKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))

                    Text("=")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)

                    TextField("value", text: $newAttrValue)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 10, design: .monospaced))

                    Button(action: addAttribute) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(newAttrKey.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear { loadValues() }
    }

    private func addAttribute() {
        let key = newAttrKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        node.attributes[key] = newAttrValue
        customAttributes.append((key: key, value: newAttrValue))
        newAttrKey = ""
        newAttrValue = ""
    }

    private func loadValues() {
        elementID = node.attributes["id"] ?? ""
        cssClass = node.attributes["class"] ?? ""
        customAttributes = node.attributes
            .filter { !Self.managedAttributes.contains($0.key) }
            .map { (key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }
}
