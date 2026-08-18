import AppKit

/// External links the app opens in the user's browser.
enum Links {
    /// Ko-fi tip page. Ko-fi hosts the entire checkout — the app only links out.
    static let kofi = URL(string: "https://ko-fi.com/zehash")!

    static func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
