import Foundation

/// Generates +layout.svelte files for pages marked as layouts.
struct LayoutGenerator {

    /// Returns the route path and the Svelte layout file content.
    func generate(page: Page, breakpoints: [Breakpoint], tokens: [DesignToken]) -> (path: String, content: String) {
        let routePath = svelteLayoutPath(for: page)
        var classCounter = 0

        // Assign CSS class names to nodes
        var classMap: [UUID: String] = [:]
        assignClasses(to: page.rootNodes.sorted { $0.sortOrder < $1.sortOrder }, classMap: &classMap, counter: &classCounter)

        // Generate HTML with <slot /> for child content
        let html = page.rootNodes
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { renderNode($0, classMap: classMap, indent: 0) }
            .joined(separator: "\n")

        // Import app.css in layout
        let scriptSection = "<script>\n  import '../app.css';\n</script>\n\n"

        // Generate CSS
        let css = generateScopedCSS(page: page, classMap: classMap, breakpoints: breakpoints)
        let styleSection = css.isEmpty ? "" : "\n<style>\n\(css)\n</style>\n"

        let content = "\(scriptSection)\(html)\n\n<slot />\(styleSection)"
        return (path: routePath, content: content)
    }

    // MARK: - Route Path

    private func svelteLayoutPath(for page: Page) -> String {
        let slug = page.slug.trimmingCharacters(in: .whitespaces)
        if slug.isEmpty || page.route == "/" {
            return "src/routes/+layout.svelte"
        }
        return "src/routes/\(slug)/+layout.svelte"
    }

    // MARK: - Class Assignment

    private func assignClasses(to nodes: [Node], classMap: inout [UUID: String], counter: inout Int) {
        for node in nodes {
            if !node.styles.isEmpty {
                if let name = node.name, !name.isEmpty {
                    let className = name.lowercased().replacingOccurrences(of: " ", with: "-").filter { $0.isLetter || $0.isNumber || $0 == "-" }
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

    // MARK: - HTML Rendering

    private func renderNode(_ node: Node, classMap: [UUID: String], indent: Int) -> String {
        let pad = String(repeating: "  ", count: indent)
        let tag = node.nodeType.rawValue

        // Handle slot node
        if node.nodeType == .slot {
            return "\(pad)<slot />"
        }

        var attrs = buildAttributes(for: node)
        if let className = classMap[node.id] {
            attrs = " class=\"\(className)\"\(attrs)"
        }

        if node.nodeType.isSelfClosing {
            return "\(pad)<\(tag)\(attrs) />"
        }

        var lines: [String] = []
        lines.append("\(pad)<\(tag)\(attrs)>")

        if let text = node.textContent, !text.isEmpty {
            lines.append("\(pad)  \(text)")
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
            if key == "class" { continue }
            if value.isEmpty {
                attrs += " \(key)"
            } else {
                attrs += " \(key)=\"\(value)\""
            }
        }
        return attrs
    }

    // MARK: - CSS

    private func generateScopedCSS(page: Page, classMap: [UUID: String], breakpoints: [Breakpoint]) -> String {
        let allNodes = collectAllNodes(from: page)
        let defaultBreakpointID = breakpoints.first(where: { $0.isDefault })?.id
        var rules: [String] = []

        for node in allNodes {
            guard let className = classMap[node.id] else { continue }
            let properties = node.styles.filter { $0.breakpointID == nil || $0.breakpointID == defaultBreakpointID }
            guard !properties.isEmpty else { continue }
            let declarations = properties.sorted { $0.sortOrder < $1.sortOrder }.map { "    \($0.cssKey): \($0.value);" }
            rules.append("  .\(className) {\n\(declarations.joined(separator: "\n"))\n  }")
        }

        return rules.joined(separator: "\n\n")
    }

    private func collectAllNodes(from page: Page) -> [Node] {
        var result: [Node] = []
        for node in page.rootNodes.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            result.append(node)
            collectChildren(of: node, into: &result)
        }
        return result
    }

    private func collectChildren(of node: Node, into result: inout [Node]) {
        for child in node.sortedChildren {
            result.append(child)
            collectChildren(of: child, into: &result)
        }
    }
}
