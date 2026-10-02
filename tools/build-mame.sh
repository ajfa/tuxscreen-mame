#!/bin/bash
# Fetch MAME at the pinned commit, apply patches/ and build the tuxscreen subtarget.
# Result: build/mame/tuxscreen. PipeWire output is left out: MAME needs newer headers than
# Ubuntu 22.04 has, and PulseAudio or ALSA work. Uses mold when installed (linking is most of the time).
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
COMMIT=60e07cb1adcbdf6321a84f80569a8c9a3ea3b3f9
DIR=${1:-$REPO/build/mame}

if [ ! -d "$DIR/.git" ]; then
	git init -q "$DIR"
	git -C "$DIR" fetch -q --depth 1 https://github.com/mamedev/mame.git "$COMMIT"
	git -C "$DIR" checkout -q FETCH_HEAD
	git -C "$DIR" -c user.name=build -c user.email=build@localhost am -q "$REPO"/patches/*.patch
fi
cd "$DIR"

# about 2.5 GB per compile job (a few MAME units need over 2 GB each); JOBS overrides
jobs=${JOBS:-$(awk -v cpus="$(nproc)" '/MemAvailable/ { j = int($2 / 2621440); if (j < 1) j = 1; if (j > cpus) j = cpus; print j }' /proc/meminfo)}
pre=""
command -v mold >/dev/null && pre="mold -run"
args="SUBTARGET=tuxscreen SOURCES=src/mame/philips/tuxscreen.cpp NOWERROR=1 OPTIMIZE=2 SYMBOLS=0 TOOLS=0 NO_USE_PIPEWIRE=1"
echo "building with -j$jobs; full log in $DIR/build.log"
if ! $pre make $args -j"$jobs" > build.log 2>&1; then
	echo "retrying with -j1" | tee -a build.log
	$pre make $args -j1 >> build.log 2>&1 || { tail -30 build.log; exit 1; }
fi
ls -l "$DIR/tuxscreen"
