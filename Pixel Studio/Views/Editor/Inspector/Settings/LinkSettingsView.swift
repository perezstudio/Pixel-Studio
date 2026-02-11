import SwiftUI

/// Settings for <a> elements: href, target, rel, text content.
struct LinkSettingsView: View {
    let node: Node

    @State private var href: String = ""
    @State private var target: String = ""
    @State private var rel: String = ""
    @State private var textContent: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleSection("Link Settings") {
                VStack(spacing: 8) {
                    // Text content
                    HStack(spacing: 4) {
                        Text("Text")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("Link text", text: $textContent)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity)
                            .onChange(of: textContent) {
                                node.textContent = textContent.isEmpty ? nil : textContent
                            }
                    }

                    // Href
                    HStack(spacing: 4) {
                        Text("URL")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("https://...", text: $href)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity)
                            .onChange(of: href) {
                                if href.isEmpty { node.attributes.removeValue(forKey: "href") }
                                else { node.attributes["href"] = href }
                            }
                    }

                    // Target
                    HStack(spacing: 4) {
                        Text("Target")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        Picker("", selection: $target) {
                            Text("—").tag("")
                            Text("_self").tag("_self")
                            Text("_blank").tag("_blank")
                            Text("_parent").tag("_parent")
                            Text("_top").tag("_top")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .onChange(of: target) {
                            if target.isEmpty { node.attributes.removeValue(forKey: "target") }
                            else { node.attributes["target"] = target }
                        }
                    }

                    // Rel
                    HStack(spacing: 4) {
                        Text("Rel")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("noopener noreferrer", text: $rel)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity)
                            .onChange(of: rel) {
                                if rel.isEmpty { node.attributes.removeValue(forKey: "rel") }
                                else { node.attributes["rel"] = rel }
                            }
                    }
                }
            }

            Divider()
            GenericSettingsView(node: node)
        }
        .onAppear {
            href = node.attributes["href"] ?? ""
            target = node.attributes["target"] ?? ""
            rel = node.attributes["rel"] ?? ""
            textContent = node.textContent ?? ""
        }
    }
}
