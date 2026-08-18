import Foundation

/// One row in the list: either a running server or a bookmarked project that is
/// stopped or starting. The view renders `DisplayItem`s; `PortModel` builds them
/// by merging live servers with bookmarks.
struct DisplayItem: Identifiable, Hashable {

    enum RunState: Hashable { case running, stopped, starting }

    /// Health shown by the status dot.
    enum Status: Hashable {
        case running    // listening and responding to HTTP  → green
        case listening  // listening but not responding yet   → amber
        case starting   // just launched, not up yet          → amber
        case failed     // last start attempt never came up   → red
        case stopped    // bookmarked, not running            → grey
    }

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
    /// HTTP reachability for a running server: nil = not probed yet.
    let responding: Bool?

    var url: String { "http://localhost:\(port)" }
    var displayDirectory: String { Paths.homeRelative(directory) }
    var isRunning: Bool { state == .running }

    var status: Status {
        if failed { return .failed }
        switch state {
        case .starting: return .starting
        case .stopped:  return .stopped
        case .running:  return responding == false ? .listening : .running
        }
    }
}
