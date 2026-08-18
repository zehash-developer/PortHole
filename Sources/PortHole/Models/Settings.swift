import Foundation
import Combine

/// User preferences, persisted in UserDefaults under the app's bundle id.
@MainActor
final class Settings: ObservableObject {

    /// When true, only show servers whose working directory lives inside `roots`.
    @Published var filterByLocation: Bool {
        didSet { defaults.set(filterByLocation, forKey: Keys.filterByLocation) }
    }

    /// Folders that count as "my projects" (e.g. ~/Documents, ~/dev).
    @Published var roots: [String] {
        didSet { defaults.set(roots, forKey: Keys.roots) }
    }

    /// Terminal app to open project folders in (e.g. "Terminal", "iTerm", "Warp").
    @Published var terminalApp: String {
        didSet { defaults.set(terminalApp, forKey: Keys.terminalApp) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let filterByLocation = "filterByLocation"
        static let roots = "roots"
        static let terminalApp = "terminalApp"
    }

    init() {
        filterByLocation = defaults.object(forKey: Keys.filterByLocation) as? Bool ?? true
        roots = defaults.stringArray(forKey: Keys.roots) ?? [Self.defaultRoot]
        terminalApp = defaults.string(forKey: Keys.terminalApp) ?? "Terminal"
    }

    func addRoot(_ path: String) {
        guard !roots.contains(path) else { return }
        roots.append(path)
    }

    func removeRoot(_ path: String) {
        roots.removeAll { $0 == path }
    }

    /// Default project folder: ~/Documents.
    private static var defaultRoot: String {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Documents").path
    }
}
