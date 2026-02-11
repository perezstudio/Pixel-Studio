import Foundation

/// Orchestrates all code generators to produce a complete SvelteKit project.
struct SvelteKitGenerator {

    enum GenerationError: LocalizedError {
        case noPages
        case fileWriteError(String)
        case scaffoldError(String)

        var errorDescription: String? {
            switch self {
            case .noPages:
                return "Project has no pages to generate."
            case .fileWriteError(let path):
                return "Failed to write file: \(path)"
            case .scaffoldError(let message):
                return "Scaffold error: \(message)"
            }
        }
    }

    private let scaffolder = ProjectScaffolder()
    private let routeGenerator = RouteGenerator()
    private let layoutGenerator = LayoutGenerator()
    private let componentGenerator = ComponentGenerator()
    private let stylesheetGenerator = StylesheetGenerator()

    /// Generates a complete SvelteKit project at the specified output directory.
    func generate(project: Project, outputURL: URL) throws {
        let fm = FileManager.default

        guard !project.pages.isEmpty else {
            throw GenerationError.noPages
        }

        // 1. Scaffold project structure
        do {
            try scaffolder.scaffold(at: outputURL, projectName: project.name)
        } catch {
            throw GenerationError.scaffoldError(error.localizedDescription)
        }

        let breakpoints = project.breakpoints.sorted { $0.sortOrder < $1.sortOrder }
        let tokens = project.designTokens.sorted { $0.sortOrder < $1.sortOrder }

        // 2. Generate global stylesheet
        let appCSS = stylesheetGenerator.generate(project: project)
        try writeFile(appCSS, to: outputURL.appendingPathComponent("src/app.css"))

        // 3. Generate layouts (pages with isLayout = true)
        let layoutPages = project.pages.filter { $0.isLayout }.sorted { $0.sortOrder < $1.sortOrder }
        for page in layoutPages {
            let (path, content) = layoutGenerator.generate(page: page, breakpoints: breakpoints, tokens: tokens)
            let fileURL = outputURL.appendingPathComponent(path)
            try fm.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try writeFile(content, to: fileURL)
        }

        // 4. Generate routes (non-layout pages)
        let regularPages = project.pages.filter { !$0.isLayout }.sorted { $0.sortOrder < $1.sortOrder }
        for page in regularPages {
            let (path, content) = routeGenerator.generate(
                page: page,
                breakpoints: breakpoints,
                tokens: tokens,
                cssStrategy: project.cssStrategy
            )
            let fileURL = outputURL.appendingPathComponent(path)
            try fm.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try writeFile(content, to: fileURL)
        }

        // 5. Generate components
        for component in project.components {
            if let (path, content) = componentGenerator.generate(component: component, breakpoints: breakpoints) {
                let fileURL = outputURL.appendingPathComponent(path)
                try fm.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try writeFile(content, to: fileURL)
            }
        }

        // 6. Copy assets to static/
        for asset in project.assets {
            if let bookmarkData = asset.bookmarkData {
                do {
                    var isStale = false
                    let sourceURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
                    guard sourceURL.startAccessingSecurityScopedResource() else { continue }
                    defer { sourceURL.stopAccessingSecurityScopedResource() }

                    let destURL = outputURL.appendingPathComponent("static/\(asset.fileName)")
                    if fm.fileExists(atPath: destURL.path) {
                        try fm.removeItem(at: destURL)
                    }
                    try fm.copyItem(at: sourceURL, to: destURL)
                } catch {
                    print("[SvelteKitGenerator] Failed to copy asset \(asset.fileName): \(error)")
                }
            }
        }

        // 7. Generate root layout if none exists
        if layoutPages.isEmpty {
            let rootLayoutPath = outputURL.appendingPathComponent("src/routes/+layout.svelte")
            if !fm.fileExists(atPath: rootLayoutPath.path) {
                let rootLayout = "<script>\n  import '../app.css';\n</script>\n\n<slot />\n"
                try writeFile(rootLayout, to: rootLayoutPath)
            }
        }

        print("[SvelteKitGenerator] Generated project at \(outputURL.path)")
    }

    // MARK: - Helpers

    private func writeFile(_ content: String, to url: URL) throws {
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw GenerationError.fileWriteError(url.lastPathComponent)
        }
    }
}
