import Foundation

/// Guesses how to (re)start a project by inspecting its files.
enum CommandGuesser {

    /// Best-effort launch command for a project directory.
    /// Prefers a `package.json` script matching the detected tool; falls back to
    /// a sensible default.
    static func command(directory: String, tool: String, port: Int) -> String {
        if tool == "Python HTTP" {
            return "python3 -m http.server \(port > 0 ? String(port) : "8000")"
        }

        if let scripts = packageScripts(inDirectory: directory) {
            let manager = packageManager(inDirectory: directory)
            if let script = preferredScript(for: tool, among: Set(scripts)) {
                return "\(manager) run \(script)"
            }
            if let firstAlphabetical = scripts.sorted().first {
                return "\(manager) run \(firstAlphabetical)"
            }
        }
        return "npm run dev"
    }

    /// The most likely dev script for a tool, if the project defines it.
    private static func preferredScript(for tool: String, among scripts: Set<String>) -> String? {
        let preferences = tool == "Storybook"
            ? ["storybook", "storybook:dev", "sb", "dev", "start"]
            : ["dev", "start", "serve", "develop"]
        return preferences.first(where: scripts.contains)
    }

    /// Script names declared in `package.json`, or `nil` if there's no package.
    private static func packageScripts(inDirectory directory: String) -> [String]? {
        let path = directory + "/package.json"
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scripts = json["scripts"] as? [String: Any] else { return nil }
        return Array(scripts.keys)
    }

    /// Picks the package manager from the lockfile present in the directory.
    private static func packageManager(inDirectory directory: String) -> String {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: directory + "/pnpm-lock.yaml") { return "pnpm" }
        if fileManager.fileExists(atPath: directory + "/yarn.lock") { return "yarn" }
        if fileManager.fileExists(atPath: directory + "/bun.lockb") { return "bun" }
        return "npm"
    }
}
