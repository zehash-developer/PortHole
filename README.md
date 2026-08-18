# PortHole

A macOS menu-bar app that shows the dev servers you have running — which project, on which port — and lets you copy the URL, open it, jump to its folder in a terminal, stop it, or bookmark it to start again later.

No more `lsof -i :3000` to remember what's on which port.

![PortHole](docs/screenshot-dark.png)

## Features

- **Live list of running dev servers** — discovered from listening TCP ports, refreshed automatically.
- **Knows your projects** — names each server from its working directory (monorepo-aware, e.g. `acme-app/web`) and detects the tool (Storybook, Vite, Next.js, Angular, Django, Rails, and more).
- **Only your stuff** — filters to servers started from your project folders (default `~/Documents`, configurable), hiding Docker, editors, and system services.
- **One-click actions** — copy `http://localhost:<port>`, open in the browser, or open the folder in your terminal.
- **Stop a server** right from the menu bar.
- **Bookmark & restart** — star a project so it stays in the list when stopped, then hit ▶ to relaunch it (command auto-detected from `package.json`, editable).
- **Native feel** — frosted menu-bar popover, light/dark aware, "Open at login".

## Requirements

- macOS 14 or later
- Xcode / Swift toolchain (to build)

## Build & install

```bash
git clone <your-repo-url> PortHole
cd PortHole
./build-app.sh
cp -r PortHole.app /Applications/
open /Applications/PortHole.app
```

`build-app.sh` compiles a release build and assembles `PortHole.app`. The app lives in the menu bar only (no Dock icon).

## Usage

Click the menu-bar icon to open the popover.

- **⭐ star** — bookmark a project (keeps it listed when stopped).
- **↗** — open `http://localhost:<port>` in your browser.
- **▢ terminal** — open the project folder in your terminal.
- **⧉ copy** — copy the localhost URL.
- **✕** — stop the running server.
- **▶** — start a bookmarked, stopped project.
- **⚙︎ settings** — choose your terminal app, manage project folders, and edit bookmark launch commands.

## How it works

PortHole shells out to `lsof` to find listening TCP ports and `ps` to read each
process's command line, then maps ports back to projects using the process
working directory. Stopping sends `SIGTERM`; starting runs the project's command
detached in a login shell so it keeps running after PortHole quits. It needs no
special permissions and makes no network requests.

## License

[MIT](LICENSE)
