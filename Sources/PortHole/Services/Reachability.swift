import Foundation

/// Checks whether a locally-listening server is actually answering HTTP requests
/// — the difference between "port is open" and "the server is really up".
enum Reachability {

    /// True if `localhost:<port>` returns any HTTP response within a short timeout.
    /// A HEAD request keeps it cheap; even a 404/405 counts as "responding".
    static func responds(port: Int, timeout: TimeInterval = 1.5) async -> Bool {
        guard let url = URL(string: "http://localhost:\(port)/") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = timeout

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)

        do {
            let (_, response) = try await session.data(for: request)
            return response is HTTPURLResponse
        } catch {
            return false
        }
    }
}
