import Foundation

/// Launches external processes on the user's behalf: starting a project's dev
/// server (detached) and opening a project folder in the user's terminal.
enum Launcher {

    /// Starts `command` in `directory`, detached, logging to a per-project file.
    /// A login shell is used so PATH / nvm are available, and `nohup … &` keeps
    /// the server running after PortHole quits.
    static func start(directory: String, command: String) {
        guard !directory.isEmpty, !command.isEmpty else { return }
        prepareLogDirectory()
        let log = logPath(for: directory)
        let shellCommand =
            "cd \(Shell.quote(directory)) && nohup \(command) > \(Shell.quote(log)) 2>&1 &"
        Shell.launchDetached(shellCommand: shellCommand)
    }

    /// Opens `directory` in the given terminal app (falls back to "Terminal").
    static func openTerminal(directory: String, app: String) {
        guard !directory.isEmpty else { return }
        let name = app.trimmingCharacters(in: .whitespaces)
        Shell.capture("/usr/bin/open", ["-a", name.isEmpty ? "Terminal" : name, directory])
    }

    /// Log file a started project writes its output to.
    static func logPath(for directory: String) -> String {
        logDirectory + "/" + directory.replacingOccurrences(of: "/", with: "_") + ".log"
    }

    private static var logDirectory: String { NSTemporaryDirectory() + "porthole-logs" }

    private static func prepareLogDirectory() {
        try? FileManager.default.createDirectory(
            atPath: logDirectory, withIntermediateDirectories: true)
    }
}
