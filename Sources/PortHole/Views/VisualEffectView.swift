import SwiftUI
import AppKit

/// Native menu-bar translucency: the desktop blurs through the popover, matching
/// Control Center and the system menus. Adapts to light/dark automatically.
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}
