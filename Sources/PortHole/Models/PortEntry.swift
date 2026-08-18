import Foundation

/// One listening TCP port owned by one of the user's processes.
struct PortEntry: Identifiable, Hashable, Sendable {
    let pid: Int32
    let port: Int
    let command: String        // short command name, e.g. "node", "python3"
    let projectName: String     // friendly name derived from the working directory
    let directory: String       // full working-directory path ("" if unknown)
    let tool: String            // detected dev tool, e.g. "Storybook" ("" if unknown)

    var id: String { "\(pid)-\(port)" }
    var url: String { "http://localhost:\(port)" }

    /// Home-relative directory for display, e.g. `~/Documents/my-app`.
    var displayDirectory: String { Paths.homeRelative(directory) }
}
