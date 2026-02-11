import SwiftUI

/// Settings for <img> elements: src, alt, width, height, loading.
struct ImageSettingsView: View {
    let node: Node

    @State private var src: String = ""
    @State private var alt: String = ""
    @State private var imgWidth: String = ""
    @State private var imgHeight: String = ""
    @State private var loading: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleSection("Image Settings") {
                VStack(spacing: 8) {
                    attributeRow("Source", key: "src", value: $src, placeholder: "image.jpg")
                    attributeRow("Alt Text", key: "alt", value: $alt, placeholder: "Description...")
                    attributeRow("Width", key: "width", value: $imgWidth, placeholder: "auto")
                    attributeRow("Height", key: "height", value: $imgHeight, placeholder: "auto")

                    HStack(spacing: 4) {
                        Text("Loading")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        Picker("", selection: $loading) {
                            Text("—").tag("")
                            Text("eager").tag("eager")
                            Text("lazy").tag("lazy")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .onChange(of: loading) {
                            if loading.isEmpty {
                                node.attributes.removeValue(forKey: "loading")
                            } else {
                                node.attributes["loading"] = loading
                            }
                        }
                    }
                }
            }

            Divider()
            GenericSettingsView(node: node)
        }
        .onAppear { loadValues() }
    }

    private func loadValues() {
        src = node.attributes["src"] ?? ""
        alt = node.attributes["alt"] ?? ""
        imgWidth = node.attributes["width"] ?? ""
        imgHeight = node.attributes["height"] ?? ""
        loading = node.attributes["loading"] ?? ""
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
                    if value.wrappedValue.isEmpty {
                        node.attributes.removeValue(forKey: key)
                    } else {
                        node.attributes[key] = value.wrappedValue
                    }
                }
        }
    }
}
