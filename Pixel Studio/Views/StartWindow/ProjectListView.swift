import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    let onSelect: (Project) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Recent Projects")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            if projects.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No projects yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Create a new project to get started")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(projects) { project in
                            ProjectRowView(project: project) {
                                onSelect(project)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
