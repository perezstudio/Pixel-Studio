import Foundation

/// Generates CSS from node styles, organized by breakpoint with media queries.
/// Also generates CSS custom properties from design tokens.
struct CSSGenerationService {

    func generate(page: Page, breakpoints: [Breakpoint], tokens: [DesignToken] = []) -> String {
        var sections: [String] = []

        // CSS Reset
        sections.append(cssReset())

        // Design token custom properties
        if !tokens.isEmpty {
            sections.append(tokenVariables(tokens))
        }

        // Collect all nodes from the page
        let allNodes = collectAllNodes(from: page)

        // Base styles (no breakpoint / default breakpoint)
        let defaultBreakpointID = breakpoints.first(where: { $0.isDefault })?.id
        let baseStyles = generateStyles(for: allNodes, breakpointID: nil, defaultBreakpointID: defaultBreakpointID)
        if !baseStyles.isEmpty {
            sections.append("/* Base Styles */\n\(baseStyles)")
        }

        // Responsive styles grouped by breakpoint
        let sortedBreakpoints = breakpoints
            .filter { !$0.isDefault }
            .sorted { $0.sortOrder < $1.sortOrder }

        for breakpoint in sortedBreakpoints {
            let styles = generateStyles(for: allNodes, breakpointID: breakpoint.id, defaultBreakpointID: nil)
            if !styles.isEmpty, let mediaQuery = breakpoint.mediaQuery {
                sections.append("/* \(breakpoint.name) */\n\(mediaQuery) {\n\(indent(styles, by: 2))\n}")
            }
        }

        return sections.joined(separator: "\n\n")
    }

    // MARK: - Style Generation

    private func generateStyles(for nodes: [Node], breakpointID: UUID?, defaultBreakpointID: UUID?) -> String {
        var rules: [String] = []

        for node in nodes {
            let properties = node.styles.filter { style in
                if let bpID = breakpointID {
                    return style.breakpointID == bpID
                } else {
                    // Base styles: nil breakpointID or matching default breakpoint
                    return style.breakpointID == nil || style.breakpointID == defaultBreakpointID
                }
            }

            guard !properties.isEmpty else { continue }

            let sortedProps = properties.sorted { $0.sortOrder < $1.sortOrder }
            let declarations = sortedProps.map { "  \($0.cssKey): \($0.value);" }
            let rule = "#node-\(node.id.uuidString) {\n\(declarations.joined(separator: "\n"))\n}"
            rules.append(rule)
        }

        return rules.joined(separator: "\n\n")
    }

    // MARK: - Token Variables

    private func tokenVariables(_ tokens: [DesignToken]) -> String {
        let vars = tokens
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { "  \($0.cssVariableName): \($0.value);" }
        return ":root {\n\(vars.joined(separator: "\n"))\n}"
    }

    // MARK: - CSS Reset

    private func cssReset() -> String {
        return """
        /* CSS Reset */
        *, *::before, *::after {
          box-sizing: border-box;
        }
        * {
          margin: 0;
          padding: 0;
        }
        body {
          -webkit-font-smoothing: antialiased;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          font-size: 16px;
          line-height: 1.5;
          color: #1a1a1a;
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
        """
    }

    // MARK: - Helpers

    private func collectAllNodes(from page: Page) -> [Node] {
        var result: [Node] = []
        let roots = page.rootNodes.sorted { $0.sortOrder < $1.sortOrder }
        for node in roots {
            collectNodes(node, into: &result)
        }
        return result
    }

    private func collectNodes(_ node: Node, into result: inout [Node]) {
        result.append(node)
        for child in node.sortedChildren {
            collectNodes(child, into: &result)
        }
    }

    private func indent(_ text: String, by spaces: Int) -> String {
        let prefix = String(repeating: " ", count: spaces)
        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "\(prefix)\($0)" }
            .joined(separator: "\n")
    }
}
