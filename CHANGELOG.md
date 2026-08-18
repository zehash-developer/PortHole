# Changelog

All notable changes to PortHole are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.1.0]: https://github.com/zehash-developer/PortHole/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/zehash-developer/PortHole/releases/tag/v1.0.0
