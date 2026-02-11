import Foundation
import WebKit

/// Orchestrates HTML/CSS generation and preview server updates.
/// Owns the PreviewServer and render services.
@Observable
final class PreviewCoordinator {
    let server = PreviewServer()
    private let htmlRenderer = HTMLRenderService()
    private let cssGenerator = CSSGenerationService()

    private(set) var currentHTML: String = ""
    private(set) var needsReload: Bool = false
    private var reloadGeneration: Int = 0

    /// The generation counter used by WebPreviewView to detect reloads
    var generation: Int { reloadGeneration }

    // MARK: - Lifecycle

    func start() {
        server.start()
    }

    func stop() {
        server.stop()
    }

    // MARK: - Content Generation

    /// Regenerates HTML from the page model and pushes to the server.
    /// Returns true if the content actually changed.
    @discardableResult
    func regenerate(page: Page, breakpoints: [Breakpoint], tokens: [DesignToken] = []) -> Bool {
        let css = cssGenerator.generate(page: page, breakpoints: breakpoints, tokens: tokens)
        let html = htmlRenderer.render(page: page, css: css, tokens: tokens)

        guard html != currentHTML else { return false }

        currentHTML = html
        server.updateContent(html)
        reloadGeneration += 1
        needsReload = true
        return true
    }

    func markReloaded() {
        needsReload = false
    }

    // MARK: - Selection Highlighting

    func highlightNode(_ nodeID: UUID?, in webView: WKWebView) {
        let idString = nodeID?.uuidString ?? ""
        webView.evaluateJavaScript("psHighlightNode('\(idString)')") { _, error in
            if let error {
                print("[PreviewCoordinator] Highlight error: \(error)")
            }
        }
    }

    func highlightNodes(_ nodeIDs: Set<UUID>, in webView: WKWebView) {
        let idsJSON = nodeIDs.map { "'\($0.uuidString)'" }.joined(separator: ",")
        webView.evaluateJavaScript("psHighlightNodes([\(idsJSON)])") { _, error in
            if let error {
                print("[PreviewCoordinator] Multi-highlight error: \(error)")
            }
        }
    }

    func scrollToNode(_ nodeID: UUID, in webView: WKWebView) {
        webView.evaluateJavaScript("psScrollToNode('\(nodeID.uuidString)')") { _, _ in }
    }
}
