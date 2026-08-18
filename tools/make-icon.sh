#!/bin/bash
# Regenerates Resources/AppIcon.icns from tools/GenerateIcon.swift.
set -euo pipefail
cd "$(dirname "$0")/.."

ICONSET="build/AppIcon.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET" Resources

echo "▸ Drawing icon sizes…"
swift tools/GenerateIcon.swift "$ICONSET"

echo "▸ Packing AppIcon.icns…"
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns

echo "✓ Wrote Resources/AppIcon.icns"
