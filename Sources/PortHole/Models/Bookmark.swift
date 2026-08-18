import Foundation
import Combine

/// A remembered project: stays in the list when stopped, and can be relaunched.
struct Bookmark: Codable, Identifiable, Hashable {
    var directory: String      // canonical project directory (the identity)
    var name: String           // display name
    var tool: String           // detected framework, e.g. "Storybook"
    var command: String        // launch command, e.g. "npm run storybook"
    var port: Int              // last-seen / expected port (0 if unknown)

    var id: String { directory }
}

/// Persists bookmarks in UserDefaults and publishes changes to the UI.
@MainActor
final class BookmarkStore: ObservableObject {
    @Published private(set) var items: [Bookmark] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "bookmarks"

    init() { load() }

    func isBookmarked(_ directory: String) -> Bool {
        items.contains { $0.directory == directory }
    }

    func bookmark(for directory: String) -> Bookmark? {
        items.first { $0.directory == directory }
    }

    /// Adds a bookmark, replacing any existing one for the same directory.
    func add(_ bookmark: Bookmark) {
        items.removeAll { $0.directory == bookmark.directory }
        items.append(bookmark)
        save()
    }

    func remove(_ directory: String) {
        items.removeAll { $0.directory == directory }
        save()
    }

    func updateCommand(_ directory: String, to command: String) {
        guard let index = items.firstIndex(where: { $0.directory == directory }) else { return }
        items[index].command = command
        save()
    }

    /// Preview-only injection that skips persistence.
    func setPreviewItems(_ items: [Bookmark]) { self.items = items }

    // MARK: - Persistence

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
