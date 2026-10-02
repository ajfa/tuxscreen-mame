#!/usr/bin/env python3
"""Build the 4 MB flash image (MAME nvram file) for the tuxscreen driver.

usage: flash.py OUT PIECE@OFFSET ...

Example, 2.4.18 Tinyx with the stock Shannon partitions:
  flash.py corrida/nvram/tuxscreen/flash \\
      medios/roms/tuxscreen/blob-20020709.bin@0 \\
      medios/original/Tinyx/tuxscreen-kernel@0x20000 \\
      medios/original/Tinyx/tuxscreen-image.jffs2@0x100000
"""
import os
import sys

SIZE = 0x400000


def main():
    out = sys.argv[1]
    image = bytearray(b"\xff" * SIZE)
    for arg in sys.argv[2:]:
        path, offset = arg.rsplit("@", 1)
        offset = int(offset, 0)
        data = open(path, "rb").read()
        if offset + len(data) > SIZE:
            sys.exit("%s does not fit at 0x%x" % (path, offset))
        image[offset:offset + len(data)] = data
        print("0x%06x-0x%06x  %s" % (offset, offset + len(data) - 1, path))
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    open(out, "wb").write(image)


if __name__ == "__main__":
    main()
