#!/bin/bash
# Build the blob 2.0.5-pre2 boot loader for the Shannon with a current arm-none-eabi-gcc.
# Source: third_party/blob-2.0.5-pre2.tar.gz (GPL). Needs the include/ folder of
# Linux 2.4.18, fetched from kernel.org on the first run.
# Result: build/blob/blob-2.0.5-pre2-shannon.bin
set -euo pipefail

REPO=$(cd "$(dirname "$0")/.." && pwd)
W=$REPO/build/blob
mkdir -p "$W" && cd "$W"
command -v arm-none-eabi-gcc >/dev/null || { echo "missing arm-none-eabi-gcc (gcc-arm-none-eabi)"; exit 1; }

if [ ! -d linux-2.4.18/include/asm-arm ]; then
	mkdir -p linux-2.4.18
	curl -sfL https://cdn.kernel.org/pub/linux/kernel/v2.4/linux-2.4.18.tar.gz |
		tar xz -C linux-2.4.18 --strip-components=1 linux/include
fi
ln -sfn asm-arm linux-2.4.18/include/asm
ln -sfn arch-sa1100 linux-2.4.18/include/asm-arm/arch

rm -rf blob-2.0.5-pre2
tar xzf "$REPO/third_party/blob-2.0.5-pre2.tar.gz"
cd blob-2.0.5-pre2
# gcc 2.95 flag that no longer exists
grep -rl -- '-mapcs-32' . | xargs sed -i 's/-mapcs-32/-marm -fno-pic -fno-common/g'
# gcc 3.3 and later drop "unused" static tables; they must be "used"
sed -i 's/__attribute__((unused, __section__/__attribute__((used, __section__/' \
	include/blob/init.h include/blob/command.h include/blob/param_block.h
# newer gcc emits .text.startup, .rodata.str1.1 and similar sections
for s in src/blob/rest-ld-script* src/blob/start-ld-script* src/diag/*ld-script*; do
	[ -f "$s" ] || continue
	sed -i -e 's/\*(\.text)/*(.text .text.*)/' -e 's/\*(\.rodata)/*(.rodata .rodata.*)/' \
		-e 's/\*(\.data)/*(.data .data.*)/' -e 's/\*(\.bss)/*(.bss .bss.* COMMON)/' "$s"
done
touch configure.in aclocal.m4 configure Makefile.in */Makefile.in */*/Makefile.in include/blob/config.h.in 2>/dev/null || true

export CC=arm-none-eabi-gcc OBJCOPY=arm-none-eabi-objcopy LD=arm-none-eabi-ld AR=arm-none-eabi-ar RANLIB=arm-none-eabi-ranlib
LDFLAGS=--specs=nosys.specs ./configure --with-board=shannon --with-linux-prefix="$W/linux-2.4.18" \
	--host=arm-linux --build=x86_64-pc-linux-gnu > ../configure.log 2>&1 || { tail ../configure.log; exit 1; }
make LDFLAGS='-static -nostdlib' > ../make.log 2>&1 || { grep -n -i error ../make.log | head; exit 1; }
cp src/blob/blob ../blob-2.0.5-pre2-shannon.bin
ls -l "$W/blob-2.0.5-pre2-shannon.bin"
