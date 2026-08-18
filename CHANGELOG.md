# Changelog

All notable changes to PortHole are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-08-18

### Added
- **App icon** — a ship's porthole with a terminal `>_` prompt through the glass.
  Used for the Finder app and macOS notifications, so alerts no longer show a
  generic icon.
- `tools/GenerateIcon.swift` + `tools/make-icon.sh` regenerate the `.icns`
  entirely in code (no design tools needed).

### Changed
- Menu-bar glyph is now a monochrome porthole that stays crisp and adapts to
  light/dark, replacing the server-rack symbol.

## [1.2.0] - 2026-08-18

### Added
- **Restart** a running server in one step (stop + start from its bookmark command).
- **Open in Editor** — open a project folder in VS Code, Cursor, or any editor
  (configurable in Settings, alongside the terminal app).
- **Force Stop** (SIGKILL) for servers that ignore a graceful stop.
- **Failed-to-start state** with **View Log** — if a started server never comes
  up, the row flags it and you can open its output log to see why.

### Changed
- **Consolidated every row action into a single ⋯ menu**, decluttering the list:
  each server now shows just its port, name, and one actions menu (open, copy,
  terminal, editor, restart, stop, force stop, bookmark).
- Bookmarked projects show a small ⭐ indicator inline with the name.
- New server-rack menu-bar icon.

## [1.1.0] - 2026-08-18

### Added
- **Live-server notifications** — a native macOS banner with sound when a dev
  server goes live, whether it was started in a terminal or with the in-app ▶
  button. The first scan after launch is a silent baseline, and you get one
  notification per project (not per port).
- Settings toggle **"Notify when a server goes live"** (on by default).

## [1.0.0] - 2026-08-18

### Added
- Menu-bar list of running dev servers, each showing project name, port, and
  detected tool (Storybook, Vite, Next.js, Angular, Django, Rails, and more).
- Copy the `localhost:<port>` URL, open it in the browser, open the project
  folder in your terminal, or stop the server.
- Bookmark projects so they stay listed when stopped, then restart with one tap
  (launch command auto-detected from `package.json`, editable in Settings).
- Location filtering to show only servers started from your project folders
  (default `~/Documents`, configurable), hiding Docker, editors, and system noise.
- Native frosted menu-bar UI, light/dark aware, with "Open at login".

[1.3.0]: https://github.com/zehash-developer/PortHole/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/zehash-developer/PortHole/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/zehash-developer/PortHole/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/zehash-developer/PortHole/releases/tag/v1.0.0
