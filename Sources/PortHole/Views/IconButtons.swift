import SwiftUI

/// A borderless icon button with a subtle circular hover halo — the shared
/// macOS-menu idiom used for row actions and header controls.
struct IconButton: View {
    enum Size { case row, header }

    let systemName: String
    var tint: Color = .secondary
    let help: String
    var size: Size = .row
    var spinning: Bool = false
    let action: () -> Void

    @State private var hovering = false

    private var glyphSize: CGFloat { size == .header ? 13 : 12 }
    private var diameter: CGFloat { size == .header ? 26 : 24 }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: glyphSize, weight: .medium))
                .foregroundStyle(tint)
                .rotationEffect(.degrees(spinning ? 360 : 0))
                .animation(spinning
                           ? .linear(duration: 0.8).repeatForever(autoreverses: false)
                           : .default, value: spinning)
                .frame(width: diameter, height: diameter)
                .background(Circle().fill(Color.primary.opacity(hovering ? 0.11 : 0)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(help)
    }
}

/// iOS-native dismiss control: a filled circle with an X. Neutral at rest,
/// red on hover to signal the destructive stop.
struct CloseButton: View {
    let help: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        FilledCircleGlyph(
            systemName: "xmark.circle.fill", glyphSize: 16,
            foreground: hovering ? .white : .secondary,
            circle: hovering ? .red : .primary.opacity(0.13),
            help: help, hovering: $hovering, action: action)
    }
}

/// iOS-native play control for starting a stopped project.
struct PlayButton: View {
    let help: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        FilledCircleGlyph(
            systemName: "play.circle.fill", glyphSize: 17,
            foreground: hovering ? .white : .green,
            circle: hovering ? .green : .green.opacity(0.2),
            help: help, hovering: $hovering, action: action)
    }
}

/// Shared body for the two-tone filled-circle SF Symbols (close / play).
private struct FilledCircleGlyph: View {
    let systemName: String
    let glyphSize: CGFloat
    let foreground: Color
    let circle: Color
    let help: String
    @Binding var hovering: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .font(.system(size: glyphSize))
                .foregroundStyle(foreground, circle)
                .frame(width: 24, height: 24)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(help)
    }
}
