import SwiftUI

struct ComponentsTabView: View {
    let project: Project

    private var sortedComponents: [Component] {
        project.components.sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            if sortedComponents.isEmpty {
                VStack(spacing: 8) {
                    Spacer().frame(height: 40)
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text("No components yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(sortedComponents) { component in
                        ComponentRowView(component: component)
                    }
                }
            }
        }
    }
}
