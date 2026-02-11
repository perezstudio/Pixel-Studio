import SwiftUI
import SwiftData

/// Sheet for editing project breakpoints (add, modify, delete).
struct EditBreakpointsSheet: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""
    @State private var newMinWidth = ""
    @State private var newMaxWidth = ""

    private var breakpoints: [Breakpoint] {
        project.breakpoints.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Edit Breakpoints")
                .font(.title3)
                .fontWeight(.semibold)

            // Existing breakpoints
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(breakpoints) { breakpoint in
                        BreakpointEditRow(breakpoint: breakpoint, onDelete: {
                            deleteBreakpoint(breakpoint)
                        })
                    }
                }
            }
            .frame(maxHeight: 240)

            Divider()

            // Add new breakpoint
            VStack(alignment: .leading, spacing: 8) {
                Text("Add Breakpoint")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    TextField("Name", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)

                    TextField("Min Width", text: $newMinWidth)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    Text("–")

                    TextField("Max Width", text: $newMaxWidth)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    Button("Add") { addBreakpoint() }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            }
        }
        .padding(20)
        .frame(width: 480)
    }

    private func addBreakpoint() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let minW = Int(newMinWidth)
        let maxW = Int(newMaxWidth)

        let bp = Breakpoint(name: name, minWidth: minW, maxWidth: maxW)
        bp.sortOrder = project.breakpoints.count
        bp.project = project
        project.breakpoints.append(bp)

        newName = ""
        newMinWidth = ""
        newMaxWidth = ""
    }

    private func deleteBreakpoint(_ breakpoint: Breakpoint) {
        guard !breakpoint.isDefault else { return }
        modelContext.delete(breakpoint)
    }
}

// MARK: - Row

private struct BreakpointEditRow: View {
    let breakpoint: Breakpoint
    let onDelete: () -> Void

    @State private var name: String = ""
    @State private var minWidth: String = ""
    @State private var maxWidth: String = ""

    var body: some View {
        HStack(spacing: 8) {
            if breakpoint.isDefault {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 16)
            } else {
                Color.clear.frame(width: 16)
            }

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                .onChange(of: name) {
                    breakpoint.name = name
                }

            if !breakpoint.isDefault {
                TextField("Min", text: $minWidth)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .onChange(of: minWidth) {
                        breakpoint.minWidth = Int(minWidth)
                    }

                Text("–")

                TextField("Max", text: $maxWidth)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .onChange(of: maxWidth) {
                        breakpoint.maxWidth = Int(maxWidth)
                    }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            } else {
                Spacer()
                Text("Default")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .onAppear {
            name = breakpoint.name
            minWidth = breakpoint.minWidth.map(String.init) ?? ""
            maxWidth = breakpoint.maxWidth.map(String.init) ?? ""
        }
    }
}
