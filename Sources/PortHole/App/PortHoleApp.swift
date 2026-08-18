import SwiftUI
import AppKit

/// Menu-bar-only app. The icon shows a live count of running servers; clicking
/// it opens the popover (`ContentView`).
@main
struct PortHoleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = PortModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView(model: model)
        } label: {
            Image(systemName: "point.3.connected.trianglepath.dotted")
            if !model.entries.isEmpty {
                Text("\(model.entries.count)")
            }
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar only: no Dock icon, no main window.
        NSApp.setActivationPolicy(.accessory)

        // Dev-only: render light/dark preview images, then quit.
        let arguments = CommandLine.arguments
        if let flag = arguments.firstIndex(of: "--render-previews"), flag + 1 < arguments.count {
            PreviewRenderer.renderBothSchemes(to: arguments[flag + 1])
        }
    }
}
