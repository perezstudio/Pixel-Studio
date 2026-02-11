import SwiftUI

/// Commit message text field and commit button.
struct GitCommitView: View {
    let gitService: GitService
    let repoURL: URL
    let onCommitted: () -> Void

    @State private var commitMessage = ""
    @State private var isCommitting = false
    @State private var error: String?
    @State private var stageAll = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Commit")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Commit message
            TextEditor(text: $commitMessage)
                .font(.system(size: 12, design: .monospaced))
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
                .overlay(alignment: .topLeading) {
                    if commitMessage.isEmpty {
                        Text("Commit message...")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 4)
                            .allowsHitTesting(false)
                    }
                }

            // Stage all toggle
            Toggle("Stage all changes", isOn: $stageAll)
                .font(.caption)
                .toggleStyle(.checkbox)

            // Commit button
            Button {
                performCommit()
            } label: {
                HStack(spacing: 4) {
                    if isCommitting {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(isCommitting ? "Committing..." : "Commit")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCommitting)

            if let error {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Actions

    private func performCommit() {
        isCommitting = true
        error = nil

        guard repoURL.startAccessingSecurityScopedResource() else {
            error = "Cannot access repository directory."
            isCommitting = false
            return
        }

        defer {
            repoURL.stopAccessingSecurityScopedResource()
            isCommitting = false
        }

        do {
            if stageAll {
                try gitService.stageAll(at: repoURL)
            }
            try gitService.commit(message: commitMessage.trimmingCharacters(in: .whitespacesAndNewlines), at: repoURL)
            commitMessage = ""
            onCommitted()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
