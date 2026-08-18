import Foundation

/// Thin wrapper for running command-line tools. Kept tiny and dependency-free
/// so every service can reuse it instead of hand-rolling `Process`.
enum Shell {

    /// Runs `tool` with `arguments` and returns its standard output,
    /// or `nil` if the tool could not be launched.
    @discardableResult
    static func capture(_ tool: String, _ arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments

        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()

        guard (try? process.run()) != nil else { return nil }
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8)
    }

    /// Runs a command in a detached login shell that keeps running after this
    /// process (and PortHole) exits. Returns immediately.
    static func launchDetached(shellCommand: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", shellCommand]
        try? process.run()
    }

    /// Single-quotes a string for safe interpolation into a shell command.
    static func quote(_ string: String) -> String {
        "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
