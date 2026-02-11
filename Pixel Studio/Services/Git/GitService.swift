import Foundation

/// Wraps /usr/bin/git via Process for Git operations within the app sandbox.
/// Uses security-scoped bookmarks to access user-selected project directories.
@Observable
final class GitService {

    // MARK: - State

    var isRunning: Bool = false
    var lastError: String?

    // MARK: - Types

    struct GitStatus {
        let branch: String
        let staged: [FileChange]
        let unstaged: [FileChange]
        let untracked: [String]
        let isClean: Bool
    }

    struct FileChange {
        let status: ChangeStatus
        let path: String
    }

    enum ChangeStatus: String {
        case added = "A"
        case modified = "M"
        case deleted = "D"
        case renamed = "R"
        case copied = "C"
        case untracked = "?"

        var displayName: String {
            switch self {
            case .added:     return "Added"
            case .modified:  return "Modified"
            case .deleted:   return "Deleted"
            case .renamed:   return "Renamed"
            case .copied:    return "Copied"
            case .untracked: return "Untracked"
            }
        }

        var systemImage: String {
            switch self {
            case .added:     return "plus.circle.fill"
            case .modified:  return "pencil.circle.fill"
            case .deleted:   return "minus.circle.fill"
            case .renamed:   return "arrow.right.circle.fill"
            case .copied:    return "doc.on.doc.fill"
            case .untracked: return "questionmark.circle.fill"
            }
        }
    }

    enum GitError: LocalizedError {
        case notARepository
        case commandFailed(String)
        case gitNotFound
        case directoryAccessDenied

        var errorDescription: String? {
            switch self {
            case .notARepository:
                return "Not a Git repository."
            case .commandFailed(let message):
                return message
            case .gitNotFound:
                return "Git executable not found."
            case .directoryAccessDenied:
                return "Cannot access project directory."
            }
        }
    }

    // MARK: - Repository Info

    /// Checks if the directory is a Git repository.
    func isRepository(at url: URL) -> Bool {
        let gitDir = url.appendingPathComponent(".git")
        return FileManager.default.fileExists(atPath: gitDir.path)
    }

    /// Returns the current branch name.
    func currentBranch(at url: URL) throws -> String {
        let output = try runGit(["rev-parse", "--abbrev-ref", "HEAD"], at: url)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the remote URL for the given remote name.
    func remoteURL(at url: URL, remote: String = "origin") throws -> String? {
        do {
            let output = try runGit(["remote", "get-url", remote], at: url)
            let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        } catch {
            return nil
        }
    }

    // MARK: - Init / Config

    /// Initializes a new Git repository.
    func initRepo(at url: URL) throws {
        _ = try runGit(["init"], at: url)
    }

    /// Adds a remote.
    func addRemote(name: String, remoteURL: String, at url: URL) throws {
        _ = try runGit(["remote", "add", name, remoteURL], at: url)
    }

    /// Sets a remote URL (updates existing).
    func setRemoteURL(name: String, remoteURL: String, at url: URL) throws {
        _ = try runGit(["remote", "set-url", name, remoteURL], at: url)
    }

    // MARK: - Status

    /// Returns parsed git status.
    func status(at url: URL) throws -> GitStatus {
        let branch = (try? currentBranch(at: url)) ?? "main"
        let output = try runGit(["status", "--porcelain=v1"], at: url)

        var staged: [FileChange] = []
        var unstaged: [FileChange] = []
        var untracked: [String] = []

        for line in output.components(separatedBy: "\n") where !line.isEmpty {
            guard line.count >= 3 else { continue }
            let indexStatus = line[line.startIndex]
            let workTreeStatus = line[line.index(after: line.startIndex)]
            let filePath = String(line.dropFirst(3))

            // Untracked
            if indexStatus == "?" {
                untracked.append(filePath)
                continue
            }

            // Staged changes (index column)
            if indexStatus != " " && indexStatus != "?" {
                let status = ChangeStatus(rawValue: String(indexStatus)) ?? .modified
                staged.append(FileChange(status: status, path: filePath))
            }

            // Unstaged changes (work tree column)
            if workTreeStatus != " " && workTreeStatus != "?" {
                let status = ChangeStatus(rawValue: String(workTreeStatus)) ?? .modified
                unstaged.append(FileChange(status: status, path: filePath))
            }
        }

        let isClean = staged.isEmpty && unstaged.isEmpty && untracked.isEmpty
        return GitStatus(branch: branch, staged: staged, unstaged: unstaged, untracked: untracked, isClean: isClean)
    }

    // MARK: - Diff

    /// Returns the diff output (staged + unstaged).
    func diff(at url: URL) throws -> String {
        let stagedDiff = (try? runGit(["diff", "--cached"], at: url)) ?? ""
        let unstagedDiff = (try? runGit(["diff"], at: url)) ?? ""

        if stagedDiff.isEmpty && unstagedDiff.isEmpty {
            return ""
        }

        var parts: [String] = []
        if !stagedDiff.isEmpty {
            parts.append(stagedDiff)
        }
        if !unstagedDiff.isEmpty {
            parts.append(unstagedDiff)
        }
        return parts.joined(separator: "\n")
    }

    /// Returns diff for unstaged changes only.
    func diffUnstaged(at url: URL) throws -> String {
        try runGit(["diff"], at: url)
    }

    /// Returns diff for staged changes only.
    func diffStaged(at url: URL) throws -> String {
        try runGit(["diff", "--cached"], at: url)
    }

    // MARK: - Stage / Commit / Push

    /// Stages all changes.
    func stageAll(at url: URL) throws {
        _ = try runGit(["add", "-A"], at: url)
    }

    /// Stages specific files.
    func stage(files: [String], at url: URL) throws {
        guard !files.isEmpty else { return }
        _ = try runGit(["add"] + files, at: url)
    }

    /// Creates a commit with the given message.
    func commit(message: String, at url: URL) throws {
        _ = try runGit(["commit", "-m", message], at: url)
    }

    /// Pushes to the specified remote and branch.
    func push(remote: String = "origin", branch: String? = nil, setUpstream: Bool = false, at url: URL) throws {
        var args = ["push"]
        if setUpstream {
            args.append("-u")
        }
        args.append(remote)
        if let branch = branch {
            args.append(branch)
        }
        _ = try runGit(args, at: url)
    }

    // MARK: - Log

    /// Returns recent commit log entries.
    func log(at url: URL, count: Int = 20) throws -> [LogEntry] {
        let format = "%H%n%h%n%an%n%ar%n%s"
        let output = try runGit(["log", "--format=\(format)", "-n", "\(count)"], at: url)
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }

        var entries: [LogEntry] = []
        var i = 0
        while i + 4 < lines.count {
            entries.append(LogEntry(
                hash: lines[i],
                shortHash: lines[i + 1],
                author: lines[i + 2],
                relativeDate: lines[i + 3],
                message: lines[i + 4]
            ))
            i += 5
        }
        return entries
    }

    struct LogEntry {
        let hash: String
        let shortHash: String
        let author: String
        let relativeDate: String
        let message: String
    }

    // MARK: - Private

    private func runGit(_ arguments: [String], at workingDirectory: URL) throws -> String {
        let gitPath = "/usr/bin/git"
        guard FileManager.default.fileExists(atPath: gitPath) else {
            throw GitError.gitNotFound
        }

        isRunning = true
        lastError = nil
        defer { isRunning = false }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: gitPath)
        process.arguments = arguments
        process.currentDirectoryURL = workingDirectory

        // Prevent git from prompting for credentials
        var env = ProcessInfo.processInfo.environment
        env["GIT_TERMINAL_PROMPT"] = "0"
        process.environment = env

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw GitError.commandFailed("Failed to launch git: \(error.localizedDescription)")
        }

        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            let message = errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            lastError = message
            throw GitError.commandFailed(message.isEmpty ? "Git command failed with exit code \(process.terminationStatus)" : message)
        }

        return output
    }
}
