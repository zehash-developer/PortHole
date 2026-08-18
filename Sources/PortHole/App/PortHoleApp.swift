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
            // Monochrome porthole (adapts to light/dark), plus a running count.
            Image(nsImage: Self.menuBarIcon)
            if !model.entries.isEmpty {
                Text("\(model.entries.count)")
            }
        }
        .menuBarExtraStyle(.window)
    }

    /// A crisp, template porthole glyph for the menu bar: two concentric rings
    /// with rivets. Template mode lets macOS tint it for the current appearance.
    private static let menuBarIcon: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            let outer = NSBezierPath(ovalIn: NSRect(x: 1.4, y: 1.4, width: 15.2, height: 15.2))
            outer.lineWidth = 1.5
            outer.stroke()

            let inner = NSBezierPath(ovalIn: NSRect(x: 4.6, y: 4.6, width: 8.8, height: 8.8))
            inner.lineWidth = 1.1
            inner.stroke()

            // Four rivets at N/E/S/W on the outer ring.
            for (x, y) in [(9.0, 15.6), (15.6, 9.0), (9.0, 2.4), (2.4, 9.0)] {
                NSBezierPath(ovalIn: NSRect(x: x - 0.7, y: y - 0.7, width: 1.4, height: 1.4)).fill()
            }
            return true
        }
        image.isTemplate = true
        return image
    }()
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
