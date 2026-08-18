import SwiftUI
import AppKit
import UserNotifications

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
            // Server-rack glyph with a live count of running servers.
            Image(systemName: "server.rack")
            if !model.entries.isEmpty {
                Text("\(model.entries.count)")
            }
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar only: no Dock icon, no main window.
        NSApp.setActivationPolicy(.accessory)

        // Dev-only: render light/dark preview images, then quit. Returns before
        // any notification setup so the bare render binary never touches it.
        let arguments = CommandLine.arguments
        if let flag = arguments.firstIndex(of: "--render-previews"), flag + 1 < arguments.count {
            PreviewRenderer.renderBothSchemes(to: arguments[flag + 1])
            return
        }

        UNUserNotificationCenter.current().delegate = self
        Notifier.requestAuthorization()
    }

    /// Show the banner + play the sound even while PortHole is the active app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
