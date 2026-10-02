# Philips TuxScreen (IS2630 "Shannon") in MAME

A MAME driver for the Philips IS2630 screen phone, known as the TuxScreen
after the community project that replaced its Inferno firmware with Linux.
It boots the four Linux systems released for it in 2002:

| System | Boot loader | What you get |
|---|---|---|
| Tinyx 0.6 | blob 2002-07-09 | the Tinyx X server |
| Tinyx, April 2002 | blob 2.0.5-pre2 | Tinyx with the matchbox window manager |
| PicoGUI 0.1 | blob 2.0.5-pre2 | PicoGUI with its omnibar and demo applications |
| Microwindows | blob 2.0.5-pre2 | Nano-X with touchscreen support |

The machine: SA-1100 at 191.7 MHz, 16 MB of DRAM, 4 MB of AMD flash, UCB1200
codec (touchscreen, audio, telecom), 640x480 dual-scan colour STN, IR
keyboard and a serial console.

## What is here

- `patches/`: the driver (`src/mame/philips/tuxscreen.cpp`) and the fixes it
  needs elsewhere in MAME, against MAME commit `60e07cb1`.
- `tools/build-mame.sh`: fetches MAME at that commit, applies the patch and
  builds the `tuxscreen` subtarget.
- `tools/build-blob.sh`: builds blob 2.0.5-pre2 for the Shannon with a current
  `arm-none-eabi-gcc` (source in `third_party/`, GPL).
- `tools/build-flashes.sh` and `tools/flash.py`: build the 4 MB flash image of
  each system from the original images.
- `tools/test-boot.sh` and `tools/console.py`: boot all four without a window,
  log in on the serial console and check that the system answers.

## Fixes outside the driver

| Where | What |
|---|---|
| ARM7 core | SA-11x0 wait for interrupt (`c15, c8, 2`): from 27 % to over 150 % of real speed |
| UCB1200 | ADC-done interrupt (the kernel probes it) and touch |
| SA-1110 UART3 | receiver idle interrupt; UTSR0 and UTSR1 were swapped |
| SA-1110 Ser2 (ICP) | the UART receiver was an empty stub; same register swap |
| UI | `skip_warnings` in `ui.ini` is honoured |

## What you need (not included)

The TuxScreen images as distributed in 2002, in one folder with the
subfolders `Tinyx`, `Tinyx 0.6`, `picogui` and `Microwindows`
(`Microwindows/touchscreen` holds its kernel and jffs2 image). `Tinyx 0.6`
also holds `blob-20020709`, which MAME uses as the boot ROM.

Linux packages (Debian/Ubuntu names): `git make g++ python3 libsdl2-dev
libsdl2-ttf-dev libfontconfig-dev libpulse-dev libasound2-dev qtbase5-dev
gcc-arm-none-eabi curl`. `mold` is optional and makes linking much faster.

## Build and run

```sh
tools/build-mame.sh                      # 30 to 60 minutes; build/mame/tuxscreen
tools/build-blob.sh                      # build/blob/blob-2.0.5-pre2-shannon.bin
tools/build-flashes.sh /path/to/tuxscreen-images
tools/test-boot.sh                       # optional, about 2 minutes, no window
```

To run one system, copy its flash where MAME keeps the driver's NVRAM:

```sh
mkdir -p nvram/tuxscreen
cp build/flash/picogui/flash nvram/tuxscreen/flash
build/mame/tuxscreen tuxscreen -rompath build/roms -window -nomaximize -serial pty
```

The flash is written back on exit, so start from a fresh copy to get the
system as distributed. Log in as `root`, no password. The serial console
(115200 baud) appears on the pseudo-terminal MAME names in its log; the IR
keyboard is the host keyboard and the touchscreen follows the mouse.

Nano-X (Microwindows) needs `tty1` as its controlling terminal: log in with
the keyboard, not on the serial console. To shut down, `sync` and `halt`;
the "Kernel panic: Attempted to kill init!" that follows "System halted" is
harmless.

## Known limits

- PicoGUI: two applications open at once saturate the emulated SA-1100.
- PicoGUI: the touchscreen driver polls and misses very short taps; the
  driver holds each touch for 200 ms.
- The modem DSP and audio are not emulated.

## License

BSD 3-Clause, like the MAME files it changes; see `LICENSE`.
`third_party/blob-2.0.5-pre2.tar.gz` is GPL, see the `COPYING` file inside it.
