import Foundation
import Network

/// Lightweight local HTTP server using NWListener for serving preview HTML.
/// Runs on localhost with an auto-assigned port.
@Observable
final class PreviewServer {
    private var listener: NWListener?
    private var htmlContent: String = ""
    private(set) var port: UInt16 = 0
    private(set) var isRunning: Bool = false

    var serverURL: URL? {
        guard isRunning, port > 0 else { return nil }
        return URL(string: "http://127.0.0.1:\(port)/")
    }

    // MARK: - Lifecycle

    func start() {
        guard listener == nil else { return }

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        do {
            listener = try NWListener(using: params, on: .any)
        } catch {
            print("[PreviewServer] Failed to create listener: \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                if let listenerPort = self.listener?.port {
                    self.port = listenerPort.rawValue
                    self.isRunning = true
                    print("[PreviewServer] Listening on port \(listenerPort.rawValue)")
                }
            case .failed(let error):
                print("[PreviewServer] Failed: \(error)")
                self.isRunning = false
            case .cancelled:
                self.isRunning = false
            default:
                break
            }
        }

        listener?.start(queue: .main)
    }

    func stop() {
        listener?.cancel()
        listener = nil
        port = 0
        isRunning = false
    }

    func updateContent(_ html: String) {
        htmlContent = html
    }

    // MARK: - Connection Handling

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self else {
                connection.cancel()
                return
            }

            if let data, let request = String(data: data, encoding: .utf8) {
                let response = self.handleRequest(request)
                connection.send(content: response, completion: .contentProcessed { _ in
                    connection.cancel()
                })
            } else {
                connection.cancel()
            }
        }
    }

    private func handleRequest(_ request: String) -> Data {
        // Parse the request path
        let lines = request.split(separator: "\r\n")
        guard let requestLine = lines.first else {
            return httpResponse(status: "400 Bad Request", contentType: "text/plain", body: "Bad Request")
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else {
            return httpResponse(status: "400 Bad Request", contentType: "text/plain", body: "Bad Request")
        }

        let path = String(parts[1])

        switch path {
        case "/", "/index.html":
            return httpResponse(status: "200 OK", contentType: "text/html", body: htmlContent)
        case "/health":
            return httpResponse(status: "200 OK", contentType: "text/plain", body: "ok")
        default:
            return httpResponse(status: "404 Not Found", contentType: "text/plain", body: "Not Found")
        }
    }

    private func httpResponse(status: String, contentType: String, body: String) -> Data {
        let bodyData = Data(body.utf8)
        let header = "HTTP/1.1 \(status)\r\nContent-Type: \(contentType); charset=utf-8\r\nContent-Length: \(bodyData.count)\r\nConnection: close\r\nCache-Control: no-cache, no-store\r\n\r\n"
        return Data(header.utf8) + bodyData
    }
}
