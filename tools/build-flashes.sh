#!/bin/bash
# Build the 4 MB flash image of each system, and the boot ROM the driver needs.
# Usage: build-flashes.sh <media folder>
#   <media folder>  the original TuxScreen archive, extracted: it holds "Tinyx",
#                   "Tinyx 0.6", "picogui" and "Microwindows"
# Needs build/blob/blob-2.0.5-pre2-shannon.bin (tools/build-blob.sh).
# Result: build/flash/<system>/flash and build/roms/tuxscreen/blob-20020709.bin
set -euo pipefail

M=${1:?usage: build-flashes.sh <media folder>}
REPO=$(cd "$(dirname "$0")/.." && pwd)
B=$REPO/build
PRE2=$B/blob/blob-2.0.5-pre2-shannon.bin
OLD="$M/Tinyx 0.6/blob-20020709"
[ -f "$PRE2" ] || { echo "missing $PRE2 (run tools/build-blob.sh)"; exit 1; }
[ -f "$OLD" ] || { echo "missing $OLD"; exit 1; }
F="python3 $REPO/tools/flash.py"

# Tinyx 0.6: the blob it ships with, then the jffs2 with the kernel inside (/boot/linux).
$F "$B/flash/tinyx-0.6/flash"     "$OLD@0" "$M/Tinyx 0.6/20020501.jffs2@0x20000"
# The other three need blob 2.0.5-pre2: blob-20020709 finds their jffs2 and never tries
# the raw kernel at 0x20000.
$F "$B/flash/tinyx-2002-04/flash" "$PRE2@0" "$M/Tinyx/tuxscreen-kernel@0x20000" \
	"$M/Tinyx/tuxscreen-image.jffs2@0x100000"
$F "$B/flash/picogui/flash"       "$PRE2@0" "$M/picogui/picogui_0.1-kernel@0x20000" \
	"$M/picogui/picogui_0.1-image.jffs2@0x100000"
$F "$B/flash/microwindows/flash"  "$PRE2@0" "$M/Microwindows/touchscreen/tuxscreen-kernel@0x20000" \
	"$M/Microwindows/touchscreen/tuxscreen-image.jffs2@0x100000"

mkdir -p "$B/roms/tuxscreen"
cp "$OLD" "$B/roms/tuxscreen/blob-20020709.bin"
ls -l "$B"/flash/*/flash
