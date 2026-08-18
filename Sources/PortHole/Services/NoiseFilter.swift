import Foundation

/// Decides whether a listening process is background noise — OS daemons,
/// editors, browsers, tunnels, background agents — rather than a dev server.
///
/// lsof is run with `+c 0` so command names aren't truncated, letting these
/// prefixes/substrings match reliably.
enum NoiseFilter {

    static func isNoise(command: String) -> Bool {
        if deniedPrefixes.contains(where: { command.hasPrefix($0) }) { return true }
        if deniedSubstrings.contains(where: { command.contains($0) }) { return true }
        return false
    }

    /// Command-name prefixes that are never a dev server.
    private static let deniedPrefixes: [String] = [
        // macOS system daemons
        "rapportd", "ControlCenter", "sharingd", "remoted", "launchd",
        "identityservices", "apsd", "cloudd", "nsurlsessiond", "trustd",
        "rmd", "mDNSResponder", "netbiosd", "com.apple", "syncdefaultsd",
        "distnoted", "coreauthd", "WiFiAgent",
        // editors / IDEs (spawn many language-server & extension ports)
        "Code", "Cursor", "Windsurf", "Antigravity", "Electron",
        // browsers
        "Google Chrome", "Brave", "Safari", "firefox",
        // networking / tunnels / background apps
        "IPNExtension", "Tailscale", "cloudflared", "ngrok",
        "figma_agent", "figma", "Spotify", "Dropbox", "Slack", "zoom", "steam",
    ]

    /// Substrings that mark noise regardless of prefix — catches the many
    /// "Google Chrome Helper", "Cursor Helper (Renderer)" style processes.
    private static let deniedSubstrings: [String] = ["Helper", "(Renderer)", "(GPU)"]
}
