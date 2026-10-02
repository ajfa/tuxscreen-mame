#!/bin/bash
# Build the tuxscreen subtarget of MAME for Windows with MSYS2 (MinGW64 gcc).
# Run from a MINGW64 shell, or from Windows:
#   C:\msys64\usr\bin\env MSYSTEM=MINGW64 C:\msys64\usr\bin\bash -l tools/build-mame-windows.sh
# Needs: git, make, mingw-w64-x86_64-gcc, and a python.org Python 3 (not the Microsoft
# Store one, which fails while generating the project files).
# Optional: GENERATED=<build/generated of a Linux build of the same tree> skips the layout
# compression, which runs Python once per layout file and takes about 40 minutes.
# Result: build-win/mame/tuxscreen.exe
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
COMMIT=60e07cb1adcbdf6321a84f80569a8c9a3ea3b3f9
DIR=${1:-$REPO/build-win/mame}
JOBS=${JOBS:-4}

# the MSYS2 profile empties OS, and MAME's makefile decides by it
export OS=Windows_NT
PY=${PYTHON:-$(ls -d "$(cygpath -u "$USERPROFILE")"/AppData/Local/Programs/Python/Python3*/python.exe 2>/dev/null | tail -1)}
[ -n "$PY" ] || { echo "no python.org Python 3 found; set PYTHON=<path to python.exe>"; exit 1; }
MINGW=$(cygpath -m /mingw64)

if [ ! -d "$DIR/.git" ]; then
	git init -q "$DIR"
	git -C "$DIR" fetch -q --depth 1 https://github.com/mamedev/mame.git "$COMMIT"
	# symlinks as plain files: MSYS2 emulates them by copying, which hangs on 3rdparty tests
	git -C "$DIR" -c core.symlinks=false checkout -q FETCH_HEAD
	git -C "$DIR" -c user.name=build -c user.email=build@localhost am -q "$REPO"/patches/*.patch
fi
cd "$DIR"
if [ -n "${GENERATED:-}" ] && [ ! -d build/generated ]; then
	mkdir -p build
	cp -r "$GENERATED" build/generated
	# newer than the layout compressor, or make compresses them all again
	find build/generated -exec touch {} +
fi

args="SUBTARGET=tuxscreen SOURCES=src/mame/philips/tuxscreen.cpp NOWERROR=1 OPTIMIZE=2 SYMBOLS=0 TOOLS=0"
args="$args PTR64=1 MINGW64=$MINGW TOOLCHAIN=$MINGW/bin/ PYTHON_EXECUTABLE=$PY"
echo "building with -j$JOBS; full log in $DIR/build.log"
make $args -j"$JOBS" > build.log 2>&1 || { tail -30 build.log; exit 1; }
ls -l "$DIR/tuxscreen.exe"
