import SwiftUI

struct NewPageSheet: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var pageName = ""
    @State private var isLayout = false

    private var slug: String {
        pageName
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }

    private var route: String {
        slug.isEmpty ? "/" : "/\(slug)"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("New Page")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Page Name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("About", text: $pageName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 280)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Route")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(route)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }

                Toggle("Layout Page", isOn: $isLayout)
            }

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)

                Button("Create") { createPage() }
                    .buttonStyle(.borderedProminent)
                    .disabled(pageName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
    }

    private func createPage() {
        let name = pageName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let page = Page(name: name, route: route, slug: slug, isLayout: isLayout)
        page.sortOrder = project.pages.count
        project.pages.append(page)
        dismiss()
    }
}
