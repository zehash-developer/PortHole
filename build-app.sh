#!/bin/bash
# Builds PortHole.app — a self-contained menu-bar app bundle.
set -euo pipefail
cd "$(dirname "$0")"

APP="PortHole.app"
CONFIG="${1:-release}"

echo "▸ Compiling ($CONFIG)…"
swift build -c "$CONFIG"

BIN=".build/$CONFIG/PortHole"

echo "▸ Assembling $APP…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/PortHole"
cp Info.plist "$APP/Contents/Info.plist"

echo "▸ Ad-hoc signing…"
codesign --force --sign - "$APP" >/dev/null 2>&1 || echo "  (codesign skipped)"

echo "✓ Built $(pwd)/$APP"
echo "  Run it:   open $APP"
echo "  Install:  cp -r $APP /Applications/"
