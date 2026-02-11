import SwiftUI
import SwiftData

/// View for generating a SvelteKit project to a user-selected directory.
struct GenerateProjectView: View {
    let project: Project

    @State private var isGenerating = false
    @State private var generationResult: GenerationResult?
    @State private var outputPath: String = ""

    private enum GenerationResult {
        case success(String)
        case failure(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Output directory
            VStack(alignment: .leading, spacing: 6) {
                Text("Output Directory")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    TextField("Select a directory...", text: .constant(displayPath))
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                        .disabled(true)

                    Button("Browse...") {
                        pickOutputDirectory()
                    }
                    .controlSize(.small)
                }
            }

            // Generate button
            Button {
                generateProject()
            } label: {
                HStack(spacing: 6) {
                    if isGenerating {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "hammer.fill")
                    }
                    Text(isGenerating ? "Generating..." : "Generate SvelteKit Project")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(isGenerating || resolvedOutputURL == nil)

            // Result message
            if let result = generationResult {
                switch result {
                case .success(let message):
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                case .failure(let message):
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            // Open in Finder button (after success)
            if case .success = generationResult, let url = resolvedOutputURL {
                Button {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                        Text("Open in Finder")
                    }
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.small)
            }
        }
        .onAppear {
            loadSavedOutputPath()
        }
    }

    // MARK: - Computed

    private var displayPath: String {
        if let url = resolvedOutputURL {
            return url.path
        }
        return outputPath.isEmpty ? "No directory selected" : outputPath
    }

    private var resolvedOutputURL: URL? {
        guard let bookmarkData = project.bookmarkData else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale) else { return nil }
        return url
    }

    // MARK: - Actions

    private func pickOutputDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose where to generate the SvelteKit project"
        panel.prompt = "Select"

        guard panel.runModal() == .OK, let selectedURL = panel.url else { return }

        // Save security-scoped bookmark
        do {
            let bookmarkData = try selectedURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            project.bookmarkData = bookmarkData
            outputPath = selectedURL.path
        } catch {
            generationResult = .failure("Failed to save directory bookmark: \(error.localizedDescription)")
        }
    }

    private func loadSavedOutputPath() {
        if let url = resolvedOutputURL {
            outputPath = url.path
        }
    }

    private func generateProject() {
        guard let bookmarkData = project.bookmarkData else {
            generationResult = .failure("No output directory selected.")
            return
        }

        isGenerating = true
        generationResult = nil

        // Resolve bookmark and generate
        var isStale = false
        guard let outputURL = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale) else {
            generationResult = .failure("Cannot access output directory. Please select again.")
            isGenerating = false
            return
        }

        guard outputURL.startAccessingSecurityScopedResource() else {
            generationResult = .failure("Permission denied for output directory.")
            isGenerating = false
            return
        }

        defer {
            outputURL.stopAccessingSecurityScopedResource()
            isGenerating = false
        }

        do {
            let generator = SvelteKitGenerator()
            try generator.generate(project: project, outputURL: outputURL)
            project.updatedAt = Date()
            generationResult = .success("Project generated at \(outputURL.lastPathComponent)/")
        } catch {
            generationResult = .failure(error.localizedDescription)
        }
    }
}
