import SwiftUI
import AppKit

/// A single server / bookmark row. The port badge and project details sit on the
/// left; every action lives in one ⋯ menu on the right, so the row stays clean.
struct PortRow: View {
    @ObservedObject var model: PortModel
    let item: DisplayItem

    @State private var hovering = false

    var body: some View {
        HStack(spacing: 9) {
            statusDot
            portBadge
            details
            actionsMenu
        }
        .opacity(item.state == .stopped ? 0.75 : 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(hovering ? 0.08 : 0))
        )
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }

    // MARK: - Status dot

    private var statusDot: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
            .overlay(
                Circle().stroke(statusColor.opacity(0.35), lineWidth: 3)
                    .opacity(item.status == .running ? 1 : 0)
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 6)
            .help(statusHelp)
    }

    private var statusColor: Color {
        switch item.status {
        case .running:   return .green
        case .listening: return .orange
        case .starting:  return .orange
        case .failed:    return .red
        case .stopped:   return .secondary
        }
    }

    private var statusHelp: String {
        switch item.status {
        case .running:   return "Running — responding"
        case .listening: return "Listening — not responding to HTTP yet"
        case .starting:  return "Starting…"
        case .failed:    return "Failed to start"
        case .stopped:   return "Stopped"
        }
    }

    // MARK: - Left: badge + details

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
            HStack(spacing: 5) {
                if item.isBookmarked {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.yellow)
                }
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
                .foregroundStyle(item.failed ? Color.red.opacity(0.9) : Color.secondary.opacity(0.7))
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

    /// The dim third line, contextual to state.
    private var metaLine: String {
        if item.failed { return "Failed to start — View Log" }
        switch item.state {
        case .running:  return "\(item.command) · pid \(item.pid ?? 0)"
        case .starting: return "starting…"
        case .stopped:  return item.command.isEmpty ? "stopped" : item.command
        }
    }

    // MARK: - Right: one actions menu

    private var actionsMenu: some View {
        Menu {
            switch item.state {
            case .running:  runningActions
            case .starting: startingActions
            case .stopped:  stoppedActions
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
                .contentShape(Circle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("Actions")
    }

    @ViewBuilder private var runningActions: some View {
        Button { openInBrowser() } label: { Label("Open in Browser", systemImage: "arrow.up.forward.app") }
        Button { copyURL() } label: { Label("Copy URL", systemImage: "doc.on.doc") }
        folderActions
        Divider()
        if item.isBookmarked {
            Button { model.restart(item) } label: { Label("Restart", systemImage: "arrow.clockwise") }
        }
        bookmarkToggle
        Divider()
        Button(role: .destructive) { model.stop(item) } label: { Label("Stop", systemImage: "stop.circle") }
        Button(role: .destructive) { model.stop(item, force: true) } label: { Label("Force Stop", systemImage: "bolt.circle") }
    }

    @ViewBuilder private var stoppedActions: some View {
        Button { model.start(item) } label: { Label("Start", systemImage: "play.fill") }
        folderActions
        logAction
        Divider()
        Button(role: .destructive) { model.toggleBookmark(item) } label: {
            Label("Remove Bookmark", systemImage: "star.slash")
        }
    }

    @ViewBuilder private var startingActions: some View {
        folderActions
        logAction
    }

    @ViewBuilder private var folderActions: some View {
        if !item.directory.isEmpty {
            Button { model.openInTerminal(item.directory) } label: { Label("Open in Terminal", systemImage: "terminal") }
            Button { model.openInEditor(item.directory) } label: { Label("Open in Editor", systemImage: "chevron.left.forwardslash.chevron.right") }
        }
    }

    @ViewBuilder private var logAction: some View {
        if model.hasLog(item.directory) {
            Button { model.openLog(item.directory) } label: { Label("View Log", systemImage: "doc.text") }
        }
    }

    @ViewBuilder private var bookmarkToggle: some View {
        Button { model.toggleBookmark(item) } label: {
            Label(item.isBookmarked ? "Remove Bookmark" : "Bookmark",
                  systemImage: item.isBookmarked ? "star.slash" : "star")
        }
    }

    // MARK: - Local actions

    private func openInBrowser() {
        if let url = URL(string: item.url) { NSWorkspace.shared.open(url) }
    }

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url, forType: .string)
    }
}
