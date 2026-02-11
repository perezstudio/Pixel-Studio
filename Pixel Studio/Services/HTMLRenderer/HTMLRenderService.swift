import Foundation

/// Converts a Page's node tree into a full HTML document for canvas preview.
/// Each node gets `id="node-{uuid}"` and `data-node-id="{uuid}"` for click mapping.
struct HTMLRenderService {

    func render(page: Page, css: String, tokens: [DesignToken] = []) -> String {
        let bodyHTML = page.rootNodes
            .sorted { $0.sortOrder < $1.sortOrder }
            .filter { $0.isVisible }
            .map { renderNode($0, indent: 2) }
            .joined(separator: "\n")

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>\(escapeHTML(page.title ?? page.name))</title>
          <style>
        \(css)
          </style>
          <style>
            /* Selection highlight */
            .ps-selected {
              outline: 2px solid #007AFF !important;
              outline-offset: -1px;
            }
            .ps-hovered {
              outline: 1px dashed #007AFF55 !important;
              outline-offset: -1px;
            }
          </style>
        </head>
        <body>
        \(bodyHTML)
        \(clickHandlerScript())
        </body>
        </html>
        """
    }

    // MARK: - Node Rendering

    private func renderNode(_ node: Node, indent: Int) -> String {
        guard node.isVisible else { return "" }

        let pad = String(repeating: "  ", count: indent)
        let tag = node.nodeType.rawValue
        let nodeID = node.id.uuidString
        let attrs = buildAttributes(for: node)

        if node.nodeType.isSelfClosing {
            return "\(pad)<\(tag) id=\"node-\(nodeID)\" data-node-id=\"\(nodeID)\"\(attrs) />"
        }

        var lines: [String] = []
        lines.append("\(pad)<\(tag) id=\"node-\(nodeID)\" data-node-id=\"\(nodeID)\"\(attrs)>")

        // Text content
        if let text = node.textContent, !text.isEmpty {
            lines.append("\(pad)  \(escapeHTML(text))")
        }

        // Children
        let sortedChildren = node.sortedChildren.filter { $0.isVisible }
        for child in sortedChildren {
            lines.append(renderNode(child, indent: indent + 1))
        }

        lines.append("\(pad)</\(tag)>")
        return lines.joined(separator: "\n")
    }

    private func buildAttributes(for node: Node) -> String {
        var attrs = ""
        for (key, value) in node.attributes.sorted(by: { $0.key < $1.key }) {
            attrs += " \(escapeHTML(key))=\"\(escapeHTML(value))\""
        }
        return attrs
    }

    // MARK: - JS Click Handler

    private func clickHandlerScript() -> String {
        return """
        <script>
          // Click handler: select node
          document.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            var el = e.target;
            while (el && !el.dataset.nodeId) {
              el = el.parentElement;
            }
            if (el && el.dataset.nodeId) {
              window.webkit.messageHandlers.nodeSelected.postMessage(el.dataset.nodeId);
            }
          }, true);

          // Hover handler
          var lastHovered = null;
          document.addEventListener('mouseover', function(e) {
            var el = e.target;
            while (el && !el.dataset.nodeId) {
              el = el.parentElement;
            }
            if (lastHovered && lastHovered !== el) {
              lastHovered.classList.remove('ps-hovered');
            }
            if (el && el.dataset.nodeId) {
              el.classList.add('ps-hovered');
              lastHovered = el;
            }
          }, true);

          document.addEventListener('mouseout', function(e) {
            if (lastHovered) {
              lastHovered.classList.remove('ps-hovered');
              lastHovered = null;
            }
          }, true);

          // Functions callable from Swift
          function psHighlightNode(nodeId) {
            document.querySelectorAll('.ps-selected').forEach(function(el) {
              el.classList.remove('ps-selected');
            });
            if (nodeId) {
              var el = document.getElementById('node-' + nodeId);
              if (el) {
                el.classList.add('ps-selected');
              }
            }
          }

          function psHighlightNodes(nodeIds) {
            document.querySelectorAll('.ps-selected').forEach(function(el) {
              el.classList.remove('ps-selected');
            });
            nodeIds.forEach(function(nodeId) {
              var el = document.getElementById('node-' + nodeId);
              if (el) {
                el.classList.add('ps-selected');
              }
            });
          }

          function psScrollToNode(nodeId) {
            var el = document.getElementById('node-' + nodeId);
            if (el) {
              el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
          }
        </script>
        """
    }

    // MARK: - Helpers

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
