#!/bin/bash
# Put the Windows build, the boot ROM, the four flash images and the launchers into
# one folder. Before this: build-mame-windows.sh, and build-blob.sh plus
# build-flashes.sh (Linux or WSL).
# Result: build-win/TuxScreen-Windows
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
EXE=${1:-$REPO/build-win/mame/tuxscreen.exe}
OUT=${2:-$REPO/build-win/TuxScreen-Windows}
B=$REPO/build
[ -f "$EXE" ] || { echo "no $EXE (run tools/build-mame-windows.sh)"; exit 1; }
[ -f "$B/flash/picogui/flash" ] || { echo "no flash images in $B/flash (run tools/build-flashes.sh)"; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT/roms/tuxscreen" "$OUT/ini" "$OUT/lua"
cp "$EXE" "$OUT/tuxscreen.exe"
cp "$B/roms/tuxscreen/blob-20020709.bin" "$OUT/roms/tuxscreen/"
for os in tinyx-0.6 tinyx-2002-04 picogui microwindows; do
	mkdir -p "$OUT/flash-original/$os"
	cp "$B/flash/$os/flash" "$OUT/flash-original/$os/flash"
done
for f in "$REPO"/pack/*.bat "$REPO"/pack/README.txt "$REPO"/pack/ini/ui.ini "$REPO"/pack/lua/desktop.lua; do
	rel=${f#"$REPO"/pack/}
	sed 's/\r*$/\r/' "$f" > "$OUT/$rel"
done
ls -l "$OUT"
