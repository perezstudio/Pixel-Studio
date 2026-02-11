import SwiftUI

/// Settings for <form> elements: action, method.
struct FormSettingsView: View {
    let node: Node

    @State private var action: String = ""
    @State private var method: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleSection("Form Settings") {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Action")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("/submit", text: $action)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity)
                            .onChange(of: action) {
                                if action.isEmpty { node.attributes.removeValue(forKey: "action") }
                                else { node.attributes["action"] = action }
                            }
                    }

                    HStack(spacing: 4) {
                        Text("Method")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        Picker("", selection: $method) {
                            Text("—").tag("")
                            Text("GET").tag("get")
                            Text("POST").tag("post")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .onChange(of: method) {
                            if method.isEmpty { node.attributes.removeValue(forKey: "method") }
                            else { node.attributes["method"] = method }
                        }
                    }
                }
            }

            Divider()
            GenericSettingsView(node: node)
        }
        .onAppear {
            action = node.attributes["action"] ?? ""
            method = node.attributes["method"] ?? ""
        }
    }
}
