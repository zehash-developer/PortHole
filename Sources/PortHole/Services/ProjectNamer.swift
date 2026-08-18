import Foundation

/// Derives a friendly project name from a process's working directory.
enum ProjectNamer {

    /// Names a project from its `directory`, falling back to `command` when the
    /// directory isn't meaningful (unknown, root, or the home folder).
    ///
    /// For generic sub-folders like `web` or `app`, the parent is prepended so a
    /// monorepo package reads as `acme-app/web` rather than just `web`.
    static func name(forDirectory directory: String, fallback command: String) -> String {
        guard isMeaningful(directory) else { return command }

        let base = Paths.lastComponent(directory)
        guard !base.isEmpty else { return command }

        if genericNames.contains(base.lowercased()) {
            let parent = Paths.parentComponent(directory)
            if !parent.isEmpty { return "\(parent)/\(base)" }
        }
        return base
    }

    private static func isMeaningful(_ directory: String) -> Bool {
        !directory.isEmpty && directory != "/" && directory != NSHomeDirectory()
    }

    /// Folder names too generic to identify a project on their own.
    private static let genericNames: Set<String> = [
        "web", "app", "apps", "src", "client", "server", "frontend",
        "backend", "www", "site", "packages", "dist", "build", "public",
    ]
}
