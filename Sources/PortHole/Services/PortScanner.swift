import Foundation
import Darwin

/// Finds the user's running dev servers by combining OS process facts
/// (`ProcessInspector`) with noise filtering, location filtering, and labelling.
/// This is the high-level entry point the app calls each scan.
enum PortScanner {

    /// - Parameters:
    ///   - roots: folders that count as the user's projects.
    ///   - restrictToRoots: keep only servers whose working directory is inside `roots`.
    static func scan(roots: [String], restrictToRoots: Bool) -> [PortEntry] {
        let listeners = ownedListeners()
        let pids = listeners.map(\.pid)
        let directories = ProcessInspector.workingDirectories(forPIDs: pids)
        let commandLines = ProcessInspector.commandLines(forPIDs: pids)

        let entries = listeners.compactMap { listener in
            makeEntry(for: listener,
                      directory: directories[listener.pid],
                      commandLine: commandLines[listener.pid],
                      roots: roots,
                      restrictToRoots: restrictToRoots)
        }
        return entries.sorted { $0.port < $1.port }
    }

    /// Stop a process (same-user; no privileges required). Sends SIGTERM for a
    /// graceful stop, or SIGKILL when `force` is true.
    static func terminate(pid: Int32, force: Bool = false) {
        _ = Darwin.kill(pid, force ? SIGKILL : SIGTERM)
    }

    // MARK: - Steps

    /// This user's listening sockets, de-duplicated and with noise removed.
    /// (A process listening on both IPv4 and IPv6 reports the same port twice.)
    private static func ownedListeners() -> [ProcessInspector.Listener] {
        let me = NSUserName()
        var seen = Set<String>()
        return ProcessInspector.listeningSockets().filter { listener in
            guard listener.login == me,
                  !NoiseFilter.isNoise(command: listener.command) else { return false }
            return seen.insert("\(listener.pid)-\(listener.port)").inserted
        }
    }

    /// Builds a `PortEntry` for one listener, or `nil` when location filtering
    /// excludes it.
    private static func makeEntry(
        for listener: ProcessInspector.Listener,
        directory: String?,
        commandLine: String?,
        roots: [String],
        restrictToRoots: Bool
    ) -> PortEntry? {
        if restrictToRoots {
            guard let directory, Paths.isPath(directory, insideAnyOf: roots) else { return nil }
        }
        return PortEntry(
            pid: listener.pid,
            port: listener.port,
            command: listener.command,
            projectName: ProjectNamer.name(forDirectory: directory ?? "",
                                           fallback: listener.command),
            directory: directory ?? "",
            tool: ToolDetector.detect(commandLine: commandLine ?? listener.command,
                                      port: listener.port))
    }
}
