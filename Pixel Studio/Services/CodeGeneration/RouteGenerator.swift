import Foundation

/// Converts a Page into a +page.svelte file with clean Svelte HTML and scoped styles.
struct RouteGenerator {

    /// Returns the route path and the Svelte file content.
    func generate(page: Page, breakpoints: [Breakpoint], tokens: [DesignToken], cssStrategy: CSSStrategy) -> (path: String, content: String) {
        let routePath = svelteRoutePath(for: page)
        var classCounter = 0

        // Assign CSS class names to nodes
        var classMap: [UUID: String] = [:]
        assignClasses(to: page.rootNodes.sorted { $0.sortOrder < $1.sortOrder }, classMap: &classMap, counter: &classCounter)

        // Generate HTML
        let html = page.rootNodes
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { renderNode($0, classMap: classMap, indent: 0) }
            .joined(separator: "\n")

        // Generate script section (for component imports)
        let imports = collectComponentImports(from: page.rootNodes)
        let scriptSection = imports.isEmpty ? "" : "<script>\n\(imports.map { "  import \($0) from '$lib/components/\($0).svelte';" }.joined(separator: "\n"))\n</script>\n\n"

        // Generate svelte:head for meta
        var headSection = ""
        if page.title != nil || page.metaDescription != nil {
            var headParts: [String] = []
            if let title = page.title {
                headParts.append("  <title>\(escapeHTML(title))</title>")
            }
            if let desc = page.metaDescription {
                headParts.append("  <meta name=\"description\" content=\"\(escapeHTML(desc))\" />")
            }
            headSection = "<svelte:head>\n\(headParts.joined(separator: "\n"))\n</svelte:head>\n\n"
        }

        // Generate CSS
        let css = generateScopedCSS(page: page, classMap: classMap, breakpoints: breakpoints, tokens: tokens)
        let styleSection = css.isEmpty ? "" : "\n<style>\n\(css)\n</style>\n"

        let content = "\(scriptSection)\(headSection)\(html)\(styleSection)"
        return (path: routePath, content: content)
    }

    // MARK: - Route Path

    private func svelteRoutePath(for page: Page) -> String {
        let slug = page.slug.trimmingCharacters(in: .whitespaces)
        if slug.isEmpty || page.route == "/" {
            return "src/routes/+page.svelte"
        }
        return "src/routes/\(slug)/+page.svelte"
    }

    // MARK: - Class Assignment

    private func assignClasses(to nodes: [Node], classMap: inout [UUID: String], counter: inout Int) {
        for node in nodes {
            let hasStyles = !node.styles.isEmpty
            if hasStyles {
                if let name = node.name, !name.isEmpty {
                    let className = name
                        .lowercased()
                        .replacingOccurrences(of: " ", with: "-")
                        .filter { $0.isLetter || $0.isNumber || $0 == "-" }
                    // Ensure uniqueness
                    if classMap.values.contains(className) {
                        classMap[node.id] = "\(className)-\(counter)"
                        counter += 1
                    } else {
                        classMap[node.id] = className
                    }
                } else {
                    classMap[node.id] = "\(node.nodeType.rawValue)-\(counter)"
                    counter += 1
                }
            }
            assignClasses(to: node.sortedChildren, classMap: &classMap, counter: &counter)
        }
    }

    // MARK: - HTML Rendering (clean Svelte output)

    private func renderNode(_ node: Node, classMap: [UUID: String], indent: Int) -> String {
        let pad = String(repeating: "  ", count: indent)
        let tag = node.nodeType.rawValue
        var attrs = buildAttributes(for: node)

        // Add CSS class if node has styles
        if let className = classMap[node.id] {
            if let existing = node.attributes["class"], !existing.isEmpty {
                attrs = " class=\"\(escapeHTML(existing)) \(className)\"\(attrs.replacingOccurrences(of: " class=\"\(escapeHTML(existing))\"", with: ""))"
            } else {
                attrs = " class=\"\(className)\"\(attrs)"
            }
        }

        if node.nodeType.isSelfClosing {
            return "\(pad)<\(tag)\(attrs) />"
        }

        var lines: [String] = []
        lines.append("\(pad)<\(tag)\(attrs)>")

        if let text = node.textContent, !text.isEmpty {
            lines.append("\(pad)  \(escapeHTML(text))")
        }

        for child in node.sortedChildren {
            lines.append(renderNode(child, classMap: classMap, indent: indent + 1))
        }

        lines.append("\(pad)</\(tag)>")
        return lines.joined(separator: "\n")
    }

    private func buildAttributes(for node: Node) -> String {
        var attrs = ""
        for (key, value) in node.attributes.sorted(by: { $0.key < $1.key }) {
            // Skip 'class' — handled separately
            if key == "class" { continue }
            if value.isEmpty {
                attrs += " \(escapeHTML(key))"
            } else {
                attrs += " \(escapeHTML(key))=\"\(escapeHTML(value))\""
            }
        }
        return attrs
    }

    // MARK: - Scoped CSS

    private func generateScopedCSS(page: Page, classMap: [UUID: String], breakpoints: [Breakpoint], tokens: [DesignToken]) -> String {
        let allNodes = collectAllNodes(from: page)
        let defaultBreakpointID = breakpoints.first(where: { $0.isDefault })?.id
        var sections: [String] = []

        // Base styles
        var baseRules: [String] = []
        for node in allNodes {
            guard let className = classMap[node.id] else { continue }
            let properties = node.styles.filter { style in
                style.breakpointID == nil || style.breakpointID == defaultBreakpointID
            }
            guard !properties.isEmpty else { continue }
            let declarations = properties
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { "    \($0.cssKey): \($0.value);" }
            baseRules.append("  .\(className) {\n\(declarations.joined(separator: "\n"))\n  }")
        }
        if !baseRules.isEmpty {
            sections.append(baseRules.joined(separator: "\n\n"))
        }

        // Responsive styles
        let sortedBreakpoints = breakpoints.filter { !$0.isDefault }.sorted { $0.sortOrder < $1.sortOrder }
        for breakpoint in sortedBreakpoints {
            var bpRules: [String] = []
            for node in allNodes {
                guard let className = classMap[node.id] else { continue }
                let properties = node.styles.filter { $0.breakpointID == breakpoint.id }
                guard !properties.isEmpty else { continue }
                let declarations = properties
                    .sorted { $0.sortOrder < $1.sortOrder }
                    .map { "      \($0.cssKey): \($0.value);" }
                bpRules.append("    .\(className) {\n\(declarations.joined(separator: "\n"))\n    }")
            }
            if !bpRules.isEmpty, let mediaQuery = breakpoint.mediaQuery {
                sections.append("  \(mediaQuery) {\n\(bpRules.joined(separator: "\n\n"))\n  }")
            }
        }

        return sections.joined(separator: "\n\n")
    }

    // MARK: - Helpers

    private func collectAllNodes(from page: Page) -> [Node] {
        var result: [Node] = []
        for node in page.rootNodes.sorted(by: { $0.sortOrder < $1.sortOrder }) {
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

    private func collectComponentImports(from nodes: [Node]) -> [String] {
        var imports: Set<String> = []
        for node in nodes {
            if node.componentID != nil, let name = node.name {
                let componentName = name
                    .replacingOccurrences(of: " ", with: "")
                    .filter { $0.isLetter || $0.isNumber }
                if !componentName.isEmpty {
                    imports.insert(componentName)
                }
            }
            let childImports = collectComponentImports(from: node.sortedChildren)
            imports.formUnion(childImports)
        }
        return imports.sorted()
    }

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
