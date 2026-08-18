import Foundation

/// Asks the operating system about running processes and their sockets, using
/// `lsof` and `ps`. Returns raw facts only — filtering and labelling live elsewhere.
enum ProcessInspector {

    /// A TCP socket in the LISTEN state, as reported by lsof.
    struct Listener {
        let pid: Int32
        let port: Int
        let command: String   // short command name, e.g. "node"
        let login: String     // owning user's login name
    }

    /// Every listening TCP socket on the machine (all users).
    static func listeningSockets() -> [Listener] {
        guard let output = Shell.capture(
            "/usr/sbin/lsof",
            ["-nP", "+c", "0", "-iTCP", "-sTCP:LISTEN", "-FpcnL"]
        ) else { return [] }
        return parseListeners(fromLsof: output)
    }

    /// Working directory for each pid (pids lsof can't resolve are omitted).
    static func workingDirectories(forPIDs pids: [Int32]) -> [Int32: String] {
        guard !pids.isEmpty else { return [:] }
        guard let output = Shell.capture(
            "/usr/sbin/lsof",
            ["-a", "-d", "cwd", "-p", pidList(pids), "-Fn"]
        ) else { return [:] }
        return parseFirstNamePerPID(fromLsof: output)
    }

    /// Full command line for each pid, so callers can tell which tool is running.
    static func commandLines(forPIDs pids: [Int32]) -> [Int32: String] {
        guard !pids.isEmpty else { return [:] }
        guard let output = Shell.capture(
            "/bin/ps", ["-ww", "-o", "pid=,command=", "-p", pidList(pids)]
        ) else { return [:] }
        return parseCommandLines(fromPS: output)
    }

    // MARK: - Parsing

    private static func pidList(_ pids: [Int32]) -> String {
        pids.map(String.init).joined(separator: ",")
    }

    /// Parses `lsof -F pcnL` output. Each record is `p<pid>`, `c<command>`,
    /// `L<login>`, then one `n<socket-name>` per listening socket.
    private static func parseListeners(fromLsof output: String) -> [Listener] {
        var listeners: [Listener] = []
        var pid: Int32 = 0
        var command = ""
        var login = ""

        for line in output.split(separator: "\n") {
            guard let tag = line.first else { continue }
            let value = String(line.dropFirst())
            switch tag {
            case "p": pid = Int32(value) ?? 0; command = ""; login = ""
            case "c": command = value
            case "L": login = value
            case "n":
                if let port = parsePort(fromSocketName: value) {
                    listeners.append(Listener(pid: pid, port: port,
                                              command: command, login: login))
                }
            default: break
            }
        }
        return listeners
    }

    /// Parses `lsof -Fn`, keeping the first `n` name reported for each pid.
    private static func parseFirstNamePerPID(fromLsof output: String) -> [Int32: String] {
        var result: [Int32: String] = [:]
        var pid: Int32 = 0
        for line in output.split(separator: "\n") {
            guard let tag = line.first else { continue }
            let value = String(line.dropFirst())
            switch tag {
            case "p": pid = Int32(value) ?? 0
            case "n": if result[pid] == nil { result[pid] = value }
            default: break
            }
        }
        return result
    }

    /// Parses `ps -o pid=,command=` lines into a pid → command-line map.
    private static func parseCommandLines(fromPS output: String) -> [Int32: String] {
        var result: [Int32: String] = [:]
        for line in output.split(separator: "\n") {
            let trimmed = line.drop(while: { $0 == " " })
            guard let space = trimmed.firstIndex(of: " ") else { continue }
            if let pid = Int32(trimmed[..<space]) {
                result[pid] = String(trimmed[trimmed.index(after: space)...])
            }
        }
        return result
    }

    /// Extracts the port from a socket name: `*:3000`, `127.0.0.1:3000`, `[::1]:3000`.
    private static func parsePort(fromSocketName name: String) -> Int? {
        guard let colon = name.lastIndex(of: ":") else { return nil }
        return Int(name[name.index(after: colon)...])
    }
}
