import SwiftUI
import Combine

/// The view model behind the menu-bar popover.
///
/// It periodically scans for running dev servers, merges them with saved
/// bookmarks into `displayItems`, and exposes the actions the UI triggers
/// (bookmark, start, stop, open in terminal).
@MainActor
final class PortModel: ObservableObject {

    /// Currently-running servers, refreshed on a timer.
    @Published var entries: [PortEntry] = []
    /// True while a scan is in flight (drives the header spinner).
    @Published var isScanning = false
    /// Directories that were just asked to start and aren't listening yet.
    @Published private(set) var starting: Set<String> = []

    let settings = Settings()
    let bookmarks = BookmarkStore()

    private var scanTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    /// Project keys seen running in the previous scan, used to detect new servers.
    private var runningProjectKeys: Set<String> = []
    /// The first scan just records what's already running (no notifications for it).
    private var didEstablishBaseline = false

    private let scanInterval: TimeInterval = 5
    /// How long to keep showing a spinner for a project that was asked to start.
    private let startTimeout: TimeInterval = 9

    init() {
        refresh()
        scanTimer = Timer.scheduledTimer(withTimeInterval: scanInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        // Re-scan when settings change; re-render when bookmarks change.
        settings.objectWillChange
            .sink { [weak self] in DispatchQueue.main.async { self?.refresh() } }
            .store(in: &cancellables)
        bookmarks.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Derived state

    /// The number of running servers (excludes stopped bookmarks).
    var runningCount: Int { entries.count }

    /// Running servers merged with bookmarked-but-stopped projects, sorted with
    /// running rows first.
    var displayItems: [DisplayItem] {
        runningItems() + stoppedBookmarkItems()
    }

    // MARK: - Actions

    /// Rescan for running servers (off the main thread), then publish results.
    func refresh() {
        guard !isScanning else { return }
        isScanning = true
        let roots = settings.roots
        let restrict = settings.filterByLocation

        Task.detached(priority: .userInitiated) {
            let result = PortScanner.scan(roots: roots, restrictToRoots: restrict)
            await MainActor.run {
                self.entries = result
                // Anything now listening is no longer "starting".
                for directory in result.map(\.directory) { self.starting.remove(directory) }
                self.notifyNewlyLiveServers(in: result)
                self.isScanning = false
            }
        }
    }

    /// Notifies for each project that started listening since the previous scan.
    /// The first scan only records a baseline so existing servers stay quiet.
    private func notifyNewlyLiveServers(in result: [PortEntry]) {
        let byProject = Dictionary(grouping: result) { entry in
            entry.directory.isEmpty ? "port:\(entry.port)" : entry.directory
        }
        let currentKeys = Set(byProject.keys)
        defer { runningProjectKeys = currentKeys }

        guard didEstablishBaseline else { didEstablishBaseline = true; return }
        guard settings.notifyOnLive else { return }

        for key in currentKeys.subtracting(runningProjectKeys) {
            guard let entry = byProject[key]?.min(by: { $0.port < $1.port }) else { continue }
            Notifier.serverWentLive(name: entry.projectName, port: entry.port, tool: entry.tool)
        }
    }

    /// Bookmark the project (or remove the bookmark if it already exists).
    func toggleBookmark(_ item: DisplayItem) {
        if bookmarks.isBookmarked(item.directory) {
            bookmarks.remove(item.directory)
        } else {
            let command = CommandGuesser.command(directory: item.directory,
                                                 tool: item.tool, port: item.port)
            bookmarks.add(Bookmark(directory: item.directory, name: item.name,
                                   tool: item.tool, command: command, port: item.port))
        }
    }

    /// Launch a stopped bookmark's server and poll until it appears.
    func start(_ item: DisplayItem) {
        guard let bookmark = bookmarks.bookmark(for: item.directory),
              !bookmark.command.isEmpty else { return }

        starting.insert(item.directory)
        Launcher.start(directory: bookmark.directory, command: bookmark.command)

        for delay in [1.5, 3.0, 5.0, 8.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.refresh() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + startTimeout) { [weak self] in
            self?.starting.remove(item.directory)
        }
    }

    /// Stop a running server (SIGTERM), then reconcile.
    func stop(_ item: DisplayItem) {
        guard let pid = item.pid else { return }
        PortScanner.terminate(pid: pid)
        entries.removeAll { $0.pid == pid }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.refresh() }
    }

    /// Open a project's folder in the configured terminal app.
    func openInTerminal(_ directory: String) {
        Launcher.openTerminal(directory: directory, app: settings.terminalApp)
    }

    // MARK: - Building display items

    private func runningItems() -> [DisplayItem] {
        entries
            .sorted { $0.port < $1.port }
            .map { entry in
                DisplayItem(id: "run-\(entry.id)", name: entry.projectName,
                            directory: entry.directory, tool: entry.tool,
                            port: entry.port, pid: entry.pid, command: entry.command,
                            isBookmarked: bookmarks.isBookmarked(entry.directory),
                            state: .running)
            }
    }

    private func stoppedBookmarkItems() -> [DisplayItem] {
        let runningDirectories = Set(entries.map(\.directory))
        return bookmarks.items
            .filter { !runningDirectories.contains($0.directory) }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
            .map { bookmark in
                DisplayItem(id: "bm-\(bookmark.directory)", name: bookmark.name,
                            directory: bookmark.directory, tool: bookmark.tool,
                            port: bookmark.port, pid: nil, command: bookmark.command,
                            isBookmarked: true,
                            state: starting.contains(bookmark.directory) ? .starting : .stopped)
            }
    }
}
