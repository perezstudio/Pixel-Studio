import Foundation

/// Generates the global app.css with CSS reset, design token custom properties, and global styles.
struct StylesheetGenerator {

    func generate(project: Project) -> String {
        var sections: [String] = []

        // CSS Reset
        sections.append(cssReset())

        // Design token custom properties
        if !project.designTokens.isEmpty {
            let tokens = project.designTokens.sorted { $0.sortOrder < $1.sortOrder }
            let vars = tokens.map { "  \($0.cssVariableName): \($0.value);" }
            sections.append(":root {\n\(vars.joined(separator: "\n"))\n}")
        }

        // Base body styles
        sections.append("""
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
          font-size: 16px;
          line-height: 1.5;
          color: #1a1a1a;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }
        """)

        return sections.joined(separator: "\n\n")
    }

    // MARK: - CSS Reset

    private func cssReset() -> String {
        """
        /* Modern CSS Reset */
        *, *::before, *::after {
          box-sizing: border-box;
        }

        * {
          margin: 0;
          padding: 0;
        }

        html {
          -moz-text-size-adjust: none;
          -webkit-text-size-adjust: none;
          text-size-adjust: none;
        }

        img, picture, video, canvas, svg {
          display: block;
          max-width: 100%;
        }

        input, button, textarea, select {
          font: inherit;
        }

        p, h1, h2, h3, h4, h5, h6 {
          overflow-wrap: break-word;
        }

        a {
          color: inherit;
          text-decoration: inherit;
        }
        """
    }
}
