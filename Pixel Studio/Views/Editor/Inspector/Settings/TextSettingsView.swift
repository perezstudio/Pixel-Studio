import SwiftUI

/// Settings for text elements: multiline text content editor.
struct TextSettingsView: View {
    let node: Node

    @State private var textContent: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleSection("Text Content") {
                VStack(spacing: 6) {
                    TextEditor(text: $textContent)
                        .font(.system(size: 12))
                        .frame(minHeight: 80)
                        .border(Color.primary.opacity(0.1), width: 1)
                        .onChange(of: textContent) {
                            node.textContent = textContent.isEmpty ? nil : textContent
                        }

                    Text("Enter the text content for this element")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            Divider()
            GenericSettingsView(node: node)
        }
        .onAppear {
            textContent = node.textContent ?? ""
        }
    }
}
