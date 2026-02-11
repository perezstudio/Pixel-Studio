import SwiftUI

/// Remote URL display and push button.
struct GitPushView: View {
    let project: Project
    let gitService: GitService
    let repoURL: URL
    let currentBranch: String

    @State private var remoteURL: String = ""
    @State private var isPushing = false
    @State private var pushResult: PushResult?
    @State private var isEditingRemote = false

    private enum PushResult {
        case success
        case failure(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Remote")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Remote URL
            HStack(spacing: 4) {
                if isEditingRemote {
                    TextField("https://github.com/user/repo.git", text: $remoteURL)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .onSubmit {
                            saveRemoteURL()
                        }

                    Button {
                        saveRemoteURL()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .controlSize(.small)

                    Button {
                        isEditingRemote = false
                        loadRemoteURL()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .controlSize(.small)
                } else {
                    Text(remoteURL.isEmpty ? "No remote configured" : remoteURL)
                        .font(.caption)
                        .foregroundStyle(remoteURL.isEmpty ? .tertiary : .secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        isEditingRemote = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .controlSize(.small)
                    .buttonStyle(.borderless)
                }
            }

            // Push button
            Button {
                performPush()
            } label: {
                HStack(spacing: 4) {
                    if isPushing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    Text(isPushing ? "Pushing..." : "Push to Remote")
                }
                .frame(maxWidth: .infinity)
            }
            .controlSize(.small)
            .disabled(remoteURL.isEmpty || isPushing)

            // Result
            if let pushResult {
                switch pushResult {
                case .success:
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Pushed successfully")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                case .failure(let message):
                    Text(message)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            loadRemoteURL()
        }
    }

    // MARK: - Actions

    private func loadRemoteURL() {
        // Load from project model first, then try git
        if let saved = project.gitRemoteURL, !saved.isEmpty {
            remoteURL = saved
        } else {
            guard repoURL.startAccessingSecurityScopedResource() else { return }
            defer { repoURL.stopAccessingSecurityScopedResource() }
            if let url = try? gitService.remoteURL(at: repoURL) {
                remoteURL = url
                project.gitRemoteURL = url
            }
        }
    }

    private func saveRemoteURL() {
        isEditingRemote = false
        let trimmed = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        remoteURL = trimmed
        project.gitRemoteURL = trimmed

        guard !trimmed.isEmpty else { return }
        guard repoURL.startAccessingSecurityScopedResource() else { return }
        defer { repoURL.stopAccessingSecurityScopedResource() }

        // Try to set or add remote
        do {
            if (try? gitService.remoteURL(at: repoURL)) != nil {
                try gitService.setRemoteURL(name: "origin", remoteURL: trimmed, at: repoURL)
            } else {
                try gitService.addRemote(name: "origin", remoteURL: trimmed, at: repoURL)
            }
        } catch {
            pushResult = .failure("Failed to configure remote: \(error.localizedDescription)")
        }
    }

    private func performPush() {
        isPushing = true
        pushResult = nil

        guard repoURL.startAccessingSecurityScopedResource() else {
            pushResult = .failure("Cannot access repository directory.")
            isPushing = false
            return
        }

        defer {
            repoURL.stopAccessingSecurityScopedResource()
            isPushing = false
        }

        do {
            try gitService.push(branch: currentBranch, setUpstream: true, at: repoURL)
            pushResult = .success
        } catch {
            pushResult = .failure(error.localizedDescription)
        }
    }
}
