import SwiftUI
import AppKit
import ServiceManagement

/// The popover shown from the menu bar: a header, the list of servers /
/// bookmarks, and a footer. Swaps to `SettingsView` when the gear is tapped.
struct ContentView: View {
    @ObservedObject var model: PortModel
    @State private var showingSettings = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    private let width: CGFloat = 384

    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView(settings: model.settings,
                             bookmarks: model.bookmarks) { showingSettings = false }
            } else {
                listScreen
            }
        }
        .frame(width: width)
        .background(VisualEffectView().ignoresSafeArea())
        .onAppear { model.refresh() }
    }

    // MARK: - List screen

    private var listScreen: some View {
        let items = model.displayItems
        return VStack(spacing: 0) {
            header
            Divider().opacity(0.5)

            if items.isEmpty {
                emptyState
            } else {
                serverList(items)
            }

            Divider().opacity(0.5)
            footer
        }
    }

    private func serverList(_ items: [DisplayItem]) -> some View {
        ScrollView {
            VStack(spacing: 2) {
                ForEach(items) { item in
                    PortRow(model: model, item: item)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(height: min(CGFloat(items.count) * 58 + 12, 392))
    }

    private var header: some View {
        HStack(spacing: 9) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 1) {
                Text("Running Ports").font(.system(size: 14, weight: .semibold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Spacer()
            IconButton(systemName: "arrow.clockwise", help: "Refresh now",
                       size: .header, spinning: model.isScanning) { model.refresh() }
            IconButton(systemName: "slider.horizontal.3", help: "Settings",
                       size: .header) { showingSettings = true }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    private var subtitle: String {
        let scope = model.settings.filterByLocation ? " in your folders" : ""
        switch model.runningCount {
        case 0:  return "Nothing running" + scope
        case 1:  return "1 server running" + scope
        default: return "\(model.runningCount) servers running" + scope
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.zzz").font(.system(size: 24)).foregroundStyle(.secondary)
            Text("No dev servers running")
                .font(.system(size: 13)).foregroundStyle(.secondary)
            if model.settings.filterByLocation {
                Text("Only showing servers started from your folders.")
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
    }

    private var footer: some View {
        HStack {
            Toggle(isOn: $launchAtLogin) {
                Text("Open at login").font(.system(size: 12))
            }
            .toggleStyle(.checkbox)
            .onChange(of: launchAtLogin) { _, enabled in setLaunchAtLogin(enabled) }

            Spacer()

            Button("Quit") { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch {
            // Revert the toggle to the true system state on failure.
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }
}
