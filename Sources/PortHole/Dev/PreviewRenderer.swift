import SwiftUI
import AppKit

/// Dev-only helper (invoked with `--render-previews <dir>`) that renders the
/// popover to light and dark PNGs. It draws the real AppKit hierarchy via
/// `NSHostingView` — `ImageRenderer` can't rasterize `ScrollView`/materials —
/// which is how visual changes get verified without a running menu-bar app.
enum PreviewRenderer {

    @MainActor
    static func renderBothSchemes(to directory: String) {
        let appearances: [(scheme: ColorScheme, name: NSAppearance.Name)] =
            [(.light, .aqua), (.dark, .darkAqua)]

        for appearance in appearances {
            let model = makeSampleModel()
            let fileName = appearance.scheme == .dark ? "preview-dark.png" : "preview-light.png"
            if let png = renderPNG(model: model, appearance: appearance.name) {
                try? png.write(to: URL(fileURLWithPath: directory).appendingPathComponent(fileName))
            }
        }
        NSApp.terminate(nil)
    }

    @MainActor
    private static func renderPNG(model: PortModel, appearance: NSAppearance.Name) -> Data? {
        let hosting = NSHostingView(rootView: ContentView(model: model))
        hosting.appearance = NSAppearance(named: appearance)
        hosting.layoutSubtreeIfNeeded()
        hosting.frame = CGRect(origin: .zero, size: hosting.fittingSize)
        hosting.layoutSubtreeIfNeeded()

        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return nil }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        return rep.representation(using: .png, properties: [:])
    }

    @MainActor
    private static func makeSampleModel() -> PortModel {
        let home = NSHomeDirectory()
        let model = PortModel()
        model.entries = [
            PortEntry(pid: 4213, port: 3000, command: "node", projectName: "acme-app/web",
                      directory: home + "/Developer/acme-app/web", tool: "Next.js"),
            PortEntry(pid: 4666, port: 4321, command: "python3", projectName: "api-service",
                      directory: home + "/Developer/api-service", tool: "Python HTTP"),
            PortEntry(pid: 5120, port: 4747, command: "node", projectName: "dashboard",
                      directory: home + "/Developer/dashboard", tool: "Vite"),
        ]
        model.bookmarks.setPreviewItems([
            // Bookmarked AND running (filled star on a running row).
            Bookmark(directory: home + "/Developer/dashboard", name: "dashboard",
                     tool: "Vite", command: "npm run dev", port: 4747),
            // Bookmarked but stopped (shows the ▶ Start row).
            Bookmark(directory: home + "/Developer/design-system", name: "design-system",
                     tool: "Storybook", command: "npm run storybook", port: 6006),
        ])
        return model
    }
}
