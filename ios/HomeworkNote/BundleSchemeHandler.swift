import Foundation
import WebKit

/// Serves the app's own files (index.html and so on) from inside the app under hwnote://app/.
/// A real address, instead of file://, keeps saved items reliable between launches.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html": return "text/html"
        case "js": return "application/javascript"
        case "css": return "text/css"
        case "json": return "application/json"
        case "png": return "image/png"
        case "svg": return "image/svg+xml"
        default: return "application/octet-stream"
        }
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }
        var name = String(url.path.dropFirst())
        if name.isEmpty { name = "index.html" }
        let ns = name as NSString
        guard let fileURL = Bundle.main.url(forResource: ns.deletingPathExtension, withExtension: ns.pathExtension),
              let data = try? Data(contentsOf: fileURL) else {
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didFinish()
            return
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "\(mimeType(for: ns.pathExtension)); charset=utf-8",
                "Content-Length": String(data.count),
                "Cache-Control": "no-cache"
            ]
        )!
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
