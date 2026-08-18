import Foundation
import UserNotifications

/// Delivers native macOS notifications (with sound) when a dev server goes live.
enum Notifier {

    /// Ask the user once for permission to show notifications. Safe to call on
    /// every launch — the system only prompts the first time.
    static func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Posts a "<project> is live" banner with the default notification sound.
    static func serverWentLive(name: String, port: Int, tool: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(name) is live"
        content.body = tool.isEmpty
            ? "Running on localhost:\(port)"
            : "\(tool) · running on localhost:\(port)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
