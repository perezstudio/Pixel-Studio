import SwiftUI

/// Settings for form elements: input type, name, placeholder, required, value.
struct FormElementSettingsView: View {
    let node: Node

    @State private var inputType: String = ""
    @State private var name: String = ""
    @State private var placeholder: String = ""
    @State private var defaultValue: String = ""
    @State private var isRequired: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleSection("Form Element Settings") {
                VStack(spacing: 8) {
                    if node.nodeType == .input {
                        HStack(spacing: 4) {
                            Text("Type")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .frame(width: 60, alignment: .leading)

                            Picker("", selection: $inputType) {
                                Text("text").tag("text")
                                Text("email").tag("email")
                                Text("password").tag("password")
                                Text("number").tag("number")
                                Text("tel").tag("tel")
                                Text("url").tag("url")
                                Text("search").tag("search")
                                Text("date").tag("date")
                                Text("checkbox").tag("checkbox")
                                Text("radio").tag("radio")
                                Text("file").tag("file")
                                Text("hidden").tag("hidden")
                                Text("submit").tag("submit")
                                Text("reset").tag("reset")
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .onChange(of: inputType) {
                                node.attributes["type"] = inputType
                            }
                        }
                    }

                    attributeRow("Name", key: "name", value: $name, placeholder: "field_name")
                    attributeRow("Placeholder", key: "placeholder", value: $placeholder, placeholder: "Enter text...")
                    attributeRow("Value", key: "value", value: $defaultValue, placeholder: "")

                    HStack(spacing: 4) {
                        Text("Required")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        Toggle("", isOn: $isRequired)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .onChange(of: isRequired) {
                                if isRequired {
                                    node.attributes["required"] = ""
                                } else {
                                    node.attributes.removeValue(forKey: "required")
                                }
                            }

                        Spacer()
                    }
                }
            }

            Divider()
            GenericSettingsView(node: node)
        }
        .onAppear {
            inputType = node.attributes["type"] ?? "text"
            name = node.attributes["name"] ?? ""
            placeholder = node.attributes["placeholder"] ?? ""
            defaultValue = node.attributes["value"] ?? ""
            isRequired = node.attributes["required"] != nil
        }
    }

    private func attributeRow(_ label: String, key: String, value: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)

            TextField(placeholder, text: value)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))
                .frame(maxWidth: .infinity)
                .onChange(of: value.wrappedValue) {
                    if value.wrappedValue.isEmpty { node.attributes.removeValue(forKey: key) }
                    else { node.attributes[key] = value.wrappedValue }
                }
        }
    }
}
