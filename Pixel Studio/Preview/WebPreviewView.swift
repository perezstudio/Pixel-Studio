import SwiftUI
import WebKit

/// NSViewRepresentable wrapping WKWebView for live HTML preview.
/// Supports click-to-select via JS message handler and content reload via coordinator.
struct WebPreviewView: NSViewRepresentable {
    let coordinator_: PreviewCoordinator
    let editorState: EditorState
    let onNodeSelected: (UUID) -> Void

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Add message handler for node selection
        config.userContentController.add(context.coordinator, name: "nodeSelected")

        // Disable scrollbars on the web view itself (canvas handles scrolling)
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")

        // Store reference for JS calls
        context.coordinator.webView = webView

        // Load initial content
        if let url = coordinator_.server.serverURL {
            webView.load(URLRequest(url: url))
        } else if !coordinator_.currentHTML.isEmpty {
            webView.loadHTMLString(coordinator_.currentHTML, baseURL: nil)
        }

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Reload if content generation changed
        if coordinator_.needsReload {
            if let url = coordinator_.server.serverURL {
                webView.reload()
            } else {
                webView.loadHTMLString(coordinator_.currentHTML, baseURL: nil)
            }
            coordinator_.markReloaded()

            // Re-highlight after reload
            let nodeIDs = editorState.selectedNodeIDs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                coordinator_.highlightNodes(nodeIDs, in: webView)
            }
        }

        // Update selection highlight when selection changes (without full reload)
        context.coordinator.currentSelectedNodeIDs = editorState.selectedNodeIDs
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebPreviewView
        weak var webView: WKWebView?
        var currentSelectedNodeIDs: Set<UUID> = [] {
            didSet {
                guard currentSelectedNodeIDs != oldValue, let webView else { return }
                parent.coordinator_.highlightNodes(currentSelectedNodeIDs, in: webView)
            }
        }

        init(parent: WebPreviewView) {
            self.parent = parent
        }

        // WKScriptMessageHandler — receives node click from JS
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "nodeSelected",
                  let nodeIDString = message.body as? String,
                  let nodeID = UUID(uuidString: nodeIDString)
            else { return }

            parent.onNodeSelected(nodeID)
        }

        // WKNavigationDelegate — highlight after page load
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.coordinator_.highlightNodes(parent.editorState.selectedNodeIDs, in: webView)
        }
    }
}
