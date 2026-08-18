import Foundation

/// Recognises which dev tool a process is running from its command line,
/// with a conservative fallback for a few unambiguous default ports.
enum ToolDetector {

    /// Returns a label like "Storybook" or "Vite", or "" when unknown.
    static func detect(commandLine: String, port: Int) -> String {
        let haystack = commandLine.lowercased()
        for signature in signatures where haystack.contains(signature.needle) {
            return signature.label
        }
        return defaultToolByPort[port] ?? ""
    }

    /// Command-line substrings mapped to a tool label. Ordered most-specific first.
    private static let signatures: [(needle: String, label: String)] = [
        ("storybook", "Storybook"),
        ("react-scripts", "React"),
        ("next-server", "Next.js"), ("/next", "Next.js"), ("node_modules/.bin/next", "Next.js"),
        ("nuxt", "Nuxt"),
        ("astro", "Astro"),
        ("remix", "Remix"),
        ("gatsby", "Gatsby"),
        ("vue-cli-service", "Vue"),
        ("@angular", "Angular"), ("ng serve", "Angular"),
        ("vite", "Vite"),
        ("webpack", "Webpack"),
        ("nodemon", "Nodemon"),
        ("svelte", "Svelte"),
        ("expo", "Expo"),
        ("manage.py runserver", "Django"),
        ("uvicorn", "Uvicorn"), ("gunicorn", "Gunicorn"),
        ("flask", "Flask"),
        ("http.server", "Python HTTP"),
        ("rails", "Rails"), ("puma", "Puma"),
        ("cargo", "Cargo"), ("air", "Go/Air"),
    ]

    /// Ports whose default owner is unambiguous, used only when the command
    /// line yields nothing.
    private static let defaultToolByPort: [Int: String] = [
        6006: "Storybook",
        5173: "Vite",
        4200: "Angular",
    ]
}
