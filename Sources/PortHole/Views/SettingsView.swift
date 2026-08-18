import SwiftUI
import AppKit

/// Settings: which terminal to open folders in, which folders count as projects,
/// and per-bookmark launch commands.
struct SettingsView: View {
    @ObservedObject var settings: Settings
    @ObservedObject var bookmarks: BookmarkStore
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            navBar
            Divider().opacity(0.5)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    locationToggle
                    Divider().opacity(0.5)
                    notifyToggle
                    Divider().opacity(0.5)
                    terminalSection
                    if settings.filterByLocation {
                        Divider().opacity(0.5)
                        foldersSection
                    }
                    if !bookmarks.items.isEmpty {
                        Divider().opacity(0.5)
                        bookmarksSection
                    }
                }
                .padding(14)
            }
            .frame(maxHeight: 460)
        }
    }

    // MARK: - Sections

    private var navBar: some View {
        HStack(spacing: 8) {
            IconButton(systemName: "chevron.left", help: "Back", size: .header, action: onDone)
            Text("Settings").font(.system(size: 14, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
    }

    private var locationToggle: some View {
        Toggle(isOn: $settings.filterByLocation) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Only show servers in my folders")
                    .font(.system(size: 13, weight: .medium))
                Text("Hides Docker, editors, and system services.")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
    }

    private var notifyToggle: some View {
        Toggle(isOn: $settings.notifyOnLive) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Notify when a server goes live")
                    .font(.system(size: 13, weight: .medium))
                Text("A sound + banner as each new server starts listening.")
                    .font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
    }

    private var terminalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("OPEN FOLDER IN")
            HStack(spacing: 8) {
                Image(systemName: "terminal").font(.system(size: 12)).foregroundStyle(.tint)
                    .frame(width: 16)
                TextField("Terminal", text: $settings.terminalApp)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            HStack(spacing: 8) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 11)).foregroundStyle(.tint).frame(width: 16)
                TextField("Visual Studio Code", text: $settings.editorApp)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
            }
            Text("App names, e.g. Terminal / iTerm and Visual Studio Code / Cursor.")
                .font(.system(size: 10)).foregroundStyle(.tertiary)
        }
    }

    private var foldersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("PROJECT FOLDERS")
            if settings.roots.isEmpty {
                Text("No folders added — nothing will show.")
                    .font(.system(size: 12)).foregroundStyle(.tertiary)
            }
            ForEach(settings.roots, id: \.self) { root in
                HStack(spacing: 8) {
                    Image(systemName: "folder").font(.system(size: 12)).foregroundStyle(.tint)
                    Text(Paths.homeRelative(root)).font(.system(size: 12))
                        .lineLimit(1).truncationMode(.middle)
                    Spacer()
                    IconButton(systemName: "minus.circle.fill", tint: .red,
                               help: "Remove") { settings.removeRoot(root) }
                }
            }
            Button(action: chooseFolder) {
                Label("Add Folder…", systemImage: "plus").font(.system(size: 12))
            }
            .buttonStyle(.borderless)
            .padding(.top, 2)
        }
    }

    private var bookmarksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("BOOKMARKS")
            Text("Edit how each project starts.")
                .font(.system(size: 10)).foregroundStyle(.tertiary)
            ForEach(bookmarks.items) { bookmark in
                bookmarkRow(bookmark)
            }
        }
    }

    private func bookmarkRow(_ bookmark: Bookmark) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(.yellow)
                Text(bookmark.name).font(.system(size: 12, weight: .semibold)).lineLimit(1)
                Spacer()
                IconButton(systemName: "minus.circle.fill", tint: .red,
                           help: "Remove bookmark") { bookmarks.remove(bookmark.directory) }
            }
            HStack(spacing: 6) {
                Image(systemName: "chevron.right").font(.system(size: 9)).foregroundStyle(.tertiary)
                TextField("launch command", text: Binding(
                    get: { bookmark.command },
                    set: { bookmarks.updateCommand(bookmark.directory, to: $0) }))
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 11, design: .monospaced))
            }
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.4)
    }

    /// Presents a native folder picker and adds the chosen folder as a root.
    private func chooseFolder() {
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Add"
        panel.message = "Choose a folder that holds your coding projects"
        if panel.runModal() == .OK, let url = panel.url {
            settings.addRoot(url.path)
        }
    }
}
