import SwiftUI

/// Main Git tab composing generate, status, diff, commit, and push views.
struct GitTabView: View {
    let project: Project

    @State private var gitService = GitService()
    @State private var gitStatus: GitService.GitStatus?
    @State private var diffText = ""
    @State private var isLoading = false
    @State private var recentLog: [GitService.LogEntry] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Section 1: Generate Project
                CollapsibleSection("Generate") {
                    GenerateProjectView(project: project)
                }

                Divider()

                // Show git sections only if project has output directory
                if let repoURL = resolvedRepoURL {
                    if !isRepoInitialized(repoURL) {
                        // Init repo prompt
                        initRepoSection(repoURL: repoURL)
                    } else {
                        // Section 2: Status
                        if let status = gitStatus {
                            CollapsibleSection("Status") {
                                statusSection(status)
                            }
                        }

                        // Section 3: Changes (Diff)
                        CollapsibleSection("Changes", isExpanded: false) {
                            GitDiffView(diffText: diffText)
                                .frame(maxHeight: 300)
                        }

                        Divider()

                        // Section 4: Commit
                        GitCommitView(
                            gitService: gitService,
                            repoURL: repoURL,
                            onCommitted: { refreshGitState() }
                        )

                        Divider()

                        // Section 5: Push
                        GitPushView(
                            project: project,
                            gitService: gitService,
                            repoURL: repoURL,
                            currentBranch: gitStatus?.branch ?? "main"
                        )

                        Divider()

                        // Section 6: Recent Commits
                        if !recentLog.isEmpty {
                            CollapsibleSection("Recent Commits", isExpanded: false) {
                                logSection
                            }
                        }
                    }
                } else {
                    // No output directory
                    VStack(spacing: 6) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Generate a project first to enable Git")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
            .padding(12)
        }
        .onAppear {
            refreshGitState()
        }
    }

    // MARK: - Computed

    private var resolvedRepoURL: URL? {
        guard let bookmarkData = project.bookmarkData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
    }

    private func isRepoInitialized(_ url: URL) -> Bool {
        gitService.isRepository(at: url)
    }

    // MARK: - Init Repo

    @ViewBuilder
    private func initRepoSection(repoURL: URL) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.triangle.branch")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("No Git repository found")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                initializeRepo(at: repoURL)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("Initialize Repository")
                }
                .frame(maxWidth: .infinity)
            }
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func initializeRepo(at url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            try gitService.initRepo(at: url)
            refreshGitState()
        } catch {
            print("[GitTabView] Failed to init repo: \(error)")
        }
    }

    // MARK: - Status Section

    @ViewBuilder
    private func statusSection(_ status: GitService.GitStatus) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Branch
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(status.branch)
                    .font(.caption.bold())
            }

            if status.isClean {
                Text("Working tree clean")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                // Staged
                if !status.staged.isEmpty {
                    Text("Staged (\(status.staged.count))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    ForEach(status.staged, id: \.path) { change in
                        fileChangeRow(change)
                    }
                }

                // Unstaged
                if !status.unstaged.isEmpty {
                    Text("Modified (\(status.unstaged.count))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                    ForEach(status.unstaged, id: \.path) { change in
                        fileChangeRow(change)
                    }
                }

                // Untracked
                if !status.untracked.isEmpty {
                    Text("Untracked (\(status.untracked.count))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                    ForEach(status.untracked, id: \.self) { path in
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(path)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func fileChangeRow(_ change: GitService.FileChange) -> some View {
        HStack(spacing: 4) {
            Image(systemName: change.status.systemImage)
                .font(.caption2)
                .foregroundStyle(changeColor(for: change.status))
            Text(change.path)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func changeColor(for status: GitService.ChangeStatus) -> Color {
        switch status {
        case .added:     return .green
        case .modified:  return .orange
        case .deleted:   return .red
        case .renamed:   return .blue
        case .copied:    return .blue
        case .untracked: return .secondary
        }
    }

    // MARK: - Log Section

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(recentLog, id: \.hash) { entry in
                HStack(alignment: .top, spacing: 6) {
                    Text(entry.shortHash)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .leading)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.message)
                            .font(.caption)
                            .lineLimit(2)
                        Text("\(entry.author) \u{2022} \(entry.relativeDate)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    // MARK: - Refresh

    private func refreshGitState() {
        guard let repoURL = resolvedRepoURL else { return }
        guard repoURL.startAccessingSecurityScopedResource() else { return }
        defer { repoURL.stopAccessingSecurityScopedResource() }

        guard gitService.isRepository(at: repoURL) else {
            gitStatus = nil
            diffText = ""
            recentLog = []
            return
        }

        gitStatus = try? gitService.status(at: repoURL)
        diffText = (try? gitService.diff(at: repoURL)) ?? ""
        recentLog = (try? gitService.log(at: repoURL, count: 10)) ?? []
    }
}
