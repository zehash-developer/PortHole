import Foundation

/// One row in the list: either a running server or a bookmarked project that is
/// stopped or starting. The view renders `DisplayItem`s; `PortModel` builds them
/// by merging live servers with bookmarks.
struct DisplayItem: Identifiable, Hashable {

    enum RunState: Hashable { case running, stopped, starting }

    let id: String
    let name: String
    let directory: String
    let tool: String
    let port: Int
    let pid: Int32?
    /// Short command ("node") when running; the launch command when stopped.
    let command: String
    let isBookmarked: Bool
    let state: RunState
    /// A stopped bookmark whose last start attempt never came up.
    let failed: Bool

    var url: String { "http://localhost:\(port)" }
    var displayDirectory: String { Paths.homeRelative(directory) }
    var isRunning: Bool { state == .running }
}
