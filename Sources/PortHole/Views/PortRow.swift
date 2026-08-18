import SwiftUI
import AppKit

/// A single row: bookmark star, port badge, project details, and state-specific
/// actions (open / terminal / copy / stop when running; terminal / start when stopped).
struct PortRow: View {
    @ObservedObject var model: PortModel
    let item: DisplayItem

    @State private var copied = false
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 9) {
            bookmarkStar
            portBadge
            details
            HStack(spacing: 2) { actions }
        }
        .opacity(item.state == .stopped ? 0.7 : 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(hovering ? 0.08 : 0))
        )
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }

    // MARK: - Pieces

    private var bookmarkStar: some View {
        Button(action: { model.toggleBookmark(item) }) {
            Image(systemName: item.isBookmarked ? "star.fill" : "star")
                .font(.system(size: 12))
                .foregroundStyle(item.isBookmarked ? Color.yellow : Color.secondary.opacity(0.45))
                .frame(width: 18, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(item.isBookmarked ? "Remove bookmark" : "Bookmark — keep in the list when stopped")
    }

    @ViewBuilder private var portBadge: some View {
        Group {
            if item.state == .starting {
                ProgressView().controlSize(.small).frame(minWidth: 38, minHeight: 22)
            } else {
                Text(verbatim: item.port > 0 ? String(item.port) : "—")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(item.isRunning ? Color.accentColor : Color.secondary)
                    .frame(minWidth: 38)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(item.isRunning
                                  ? Color.accentColor.opacity(0.16)
                                  : Color.secondary.opacity(0.14))
                    )
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 6) {
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                if !item.tool.isEmpty { toolTag }
                Spacer(minLength: 0)
            }
            Text(item.displayDirectory)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Text(metaLine)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var toolTag: some View {
        Text(item.tool)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.tint)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(Capsule().fill(Color.accentColor.opacity(0.16)))
            .fixedSize()
    }

    /// The dim third line: pid when running, launch command when stopped.
    private var metaLine: String {
        switch item.state {
        case .running:  return "\(item.command) · pid \(item.pid ?? 0)"
        case .starting: return "starting…"
        case .stopped:  return item.command.isEmpty ? "stopped" : item.command
        }
    }

    @ViewBuilder private var actions: some View {
        switch item.state {
        case .running:
            IconButton(systemName: "arrow.up.forward",
                       help: "Open \(item.url)", action: openInBrowser)
            terminalButton
            IconButton(systemName: copied ? "checkmark" : "doc.on.doc",
                       tint: copied ? .green : .secondary,
                       help: "Copy \(item.url)", action: copyURL)
            CloseButton(help: "Stop this process (SIGTERM)") { model.stop(item) }

        case .starting:
            terminalButton

        case .stopped:
            terminalButton
            PlayButton(help: "Start \(item.command)") { model.start(item) }
        }
    }

    @ViewBuilder private var terminalButton: some View {
        if !item.directory.isEmpty {
            IconButton(systemName: "terminal",
                       help: "Open \(item.displayDirectory) in terminal") {
                model.openInTerminal(item.directory)
            }
        }
    }

    // MARK: - Local actions

    private func openInBrowser() {
        if let url = URL(string: item.url) { NSWorkspace.shared.open(url) }
    }

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copied = false }
    }
}
