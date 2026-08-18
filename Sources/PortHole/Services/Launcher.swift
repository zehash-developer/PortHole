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

    /// Opens `directory` in the named app (e.g. a terminal or editor).
    static func open(directory: String, inApp app: String) {
        guard !directory.isEmpty else { return }
        let name = app.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        Shell.capture("/usr/bin/open", ["-a", name, directory])
    }

    /// Opens the project's log file in the default viewer, if it exists.
    static func openLog(for directory: String) {
        let path = logPath(for: directory)
        guard FileManager.default.fileExists(atPath: path) else { return }
        Shell.capture("/usr/bin/open", [path])
    }

    /// Whether a log file exists for this project (i.e. it was started here).
    static func logExists(for directory: String) -> Bool {
        FileManager.default.fileExists(atPath: logPath(for: directory))
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
