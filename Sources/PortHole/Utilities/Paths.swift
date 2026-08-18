import Foundation

/// Small filesystem-path helpers shared across the app.
enum Paths {

    /// Resolves symlinks so two paths compare correctly (e.g. `/tmp` → `/private/tmp`).
    static func resolvingSymlinks(_ path: String) -> String {
        URL(fileURLWithPath: path).resolvingSymlinksInPath().path
    }

    /// True if `path` equals, or lives inside, any of `roots`.
    static func isPath(_ path: String, insideAnyOf roots: [String]) -> Bool {
        let target = resolvingSymlinks(path)
        return roots.contains { root in
            guard !root.isEmpty else { return false }
            let base = resolvingSymlinks(root)
            return target == base || target.hasPrefix(base + "/")
        }
    }

    /// Rewrites a home-prefixed path for display, e.g. `/Users/me/x` → `~/x`.
    /// Returns `—` for an empty path.
    static func homeRelative(_ path: String) -> String {
        guard !path.isEmpty else { return "—" }
        let home = NSHomeDirectory()
        if path == home { return "~" }
        if path.hasPrefix(home + "/") { return "~" + path.dropFirst(home.count) }
        return path
    }

    /// The last path component, e.g. `/a/b/c` → `c`.
    static func lastComponent(_ path: String) -> String {
        (path as NSString).lastPathComponent
    }

    /// The parent directory's last component, e.g. `/a/b/c` → `b`.
    static func parentComponent(_ path: String) -> String {
        lastComponent((path as NSString).deletingLastPathComponent)
    }
}
