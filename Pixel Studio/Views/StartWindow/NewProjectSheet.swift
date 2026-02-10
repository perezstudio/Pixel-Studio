import SwiftUI
import SwiftData

struct NewProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                Text("Project Name")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("My Website", text: $projectName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Create") {
                    createProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
    }

    private func createProject() {
        let name = projectName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let project = Project(name: name)

        // Add default page
        let homePage = Page(name: "Home", route: "/", slug: "")
        homePage.sortOrder = 0
        project.pages.append(homePage)

        // Add default breakpoints
        let defaults = Breakpoint.defaultBreakpoints()
        for bp in defaults {
            project.breakpoints.append(bp)
        }

        modelContext.insert(project)
        dismiss()
    }
}
