import SwiftUI

struct NewComponentSheet: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var componentName = ""
    @State private var category = "Uncategorized"

    var body: some View {
        VStack(spacing: 20) {
            Text("New Component")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Component Name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("Button", text: $componentName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 280)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("Uncategorized", text: $category)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 280)
                }
            }

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)

                Button("Create") { createComponent() }
                    .buttonStyle(.borderedProminent)
                    .disabled(componentName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
    }

    private func createComponent() {
        let name = componentName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let component = Component(name: name, category: category)
        let rootNode = Node(nodeType: .div, name: name)
        component.rootNode = rootNode
        project.components.append(component)
        dismiss()
    }
}
