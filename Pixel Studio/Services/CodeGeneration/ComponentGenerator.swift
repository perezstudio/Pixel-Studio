import Foundation

/// Generates .svelte component files from Component models.
struct ComponentGenerator {

    /// Returns the file path and Svelte component content.
    func generate(component: Component, breakpoints: [Breakpoint]) -> (path: String, content: String)? {
        guard let rootNode = component.rootNode else { return nil }

        let componentName = component.name
            .replacingOccurrences(of: " ", with: "")
            .filter { $0.isLetter || $0.isNumber }
        guard !componentName.isEmpty else { return nil }

        let filePath = "src/lib/components/\(componentName).svelte"
        var classCounter = 0
        var classMap: [UUID: String] = [:]

        assignClasses(to: [rootNode], classMap: &classMap, counter: &classCounter)

        // Render HTML
        let html = renderNode(rootNode, classMap: classMap, indent: 0)

        // Render CSS
        let css = generateScopedCSS(nodes: collectAllNodes(from: rootNode), classMap: classMap, breakpoints: breakpoints)
        let styleSection = css.isEmpty ? "" : "\n<style>\n\(css)\n</style>\n"

        let content = "\(html)\(styleSection)"
        return (path: filePath, content: content)
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
            if value.isEmpty { attrs += " \(key)" }
            else { attrs += " \(key)=\"\(value)\"" }
        }
        return attrs
    }

    // MARK: - CSS

    private func generateScopedCSS(nodes: [Node], classMap: [UUID: String], breakpoints: [Breakpoint]) -> String {
        let defaultBreakpointID = breakpoints.first(where: { $0.isDefault })?.id
        var rules: [String] = []

        for node in nodes {
            guard let className = classMap[node.id] else { continue }
            let properties = node.styles.filter { $0.breakpointID == nil || $0.breakpointID == defaultBreakpointID }
            guard !properties.isEmpty else { continue }
            let declarations = properties.sorted { $0.sortOrder < $1.sortOrder }.map { "    \($0.cssKey): \($0.value);" }
            rules.append("  .\(className) {\n\(declarations.joined(separator: "\n"))\n  }")
        }

        return rules.joined(separator: "\n\n")
    }

    private func collectAllNodes(from node: Node) -> [Node] {
        var result: [Node] = [node]
        for child in node.sortedChildren {
            result.append(contentsOf: collectAllNodes(from: child))
        }
        return result
    }
}
