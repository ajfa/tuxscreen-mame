#!/bin/bash
# Boot each of the four systems without a window, log in as root on the serial console
# and run "uname -m", which must answer armv4l. Prints PASS or FAIL for each.
set -uo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
B=$REPO/build
MAME=${MAME:-$B/mame/tuxscreen}
[ -x "$MAME" ] || { echo "no $MAME (run tools/build-mame.sh)"; exit 1; }

T=$B/test
rm -rf "$T"
fail=0
for os in tinyx-0.6 tinyx-2002-04 picogui microwindows; do
	[ -f "$B/flash/$os/flash" ] || { echo "no $B/flash/$os/flash (run tools/build-flashes.sh)"; exit 1; }
	mkdir -p "$T/$os/nvram/tuxscreen"
	cp "$B/flash/$os/flash" "$T/$os/nvram/tuxscreen/flash"
	python3 "$REPO/tools/console.py" --mame "$MAME" --rompath "$B/roms" --run "$T/$os" \
		--seconds 300 --log "$T/$os.txt" --final armv4l "login:" root "# " "uname -m" > "$T/$os.res" 2>&1 &
done
wait
for os in tinyx-0.6 tinyx-2002-04 picogui microwindows; do
	if grep -q "final True" "$T/$os.res"; then
		echo "PASS  $os"
	else
		echo "FAIL  $os ($(cat "$T/$os.res")); console in $T/$os.txt"
		fail=1
	fi
done
exit $fail
