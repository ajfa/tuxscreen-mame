TuxScreen (Philips IS2630 "Shannon") in MAME, for Windows
==========================================================

The Philips IS2630 screen phone, which the TuxScreen project turned into a
pocket Linux: StrongARM SA-1100, 16 MB of RAM, 4 MB of flash, a 640x480
touchscreen and an infrared keyboard.

Everything needed is inside this folder. Nothing to install.


WHAT TO OPEN
------------

  PICOGUI.bat           PicoGUI 0.1, from OCTOBER 2001. Kernel 2.4.7.
                        Starts on its own on its desktop, with the penguin,
                        the Applications and System menus and the clock. On
                        reaching the desktop it opens the Applications menu.
                        Keys (added by this pack, PicoGUI 0.1 has none):
                          F1   opens or closes Applications. If an
                               application is open, closes it first: PicoGUI
                               0.1 runs ONE application at a time; two at once
                               (for example Canvas and another) saturate the
                               device and everything looks frozen.
                          F2   opens or closes System
                          1-7  with a menu open, picks that entry:
                               Applications: 1 Black-Out, 2 Battleship!,
                               3 Flying Tux, 4 Canvas, 5 Dialog Demo,
                               6 Scribble, 7 PicoGUI Terminal.
                               System: 1 About PicoGUI, 2 Scotty, beam me
                               out! Scotty asks "Make it so?"; with Yes
                               PicoGUI closes and starts again on its own.
                               It does NOT turn the TuxScreen off: Linux keeps
                               running (to shut down, see HOW TO SHUT DOWN).
                          F3   closes whatever is in front: the About box (its
                               "ok"), Scotty's question ("Make it so?",
                               answers No), the open menu or the open
                               application. While an About or Scotty box is
                               up, F1 and F2 do nothing: close it first with F3.
                        Do not use Tab and Space to open the menus: a menu
                        opened that way cannot be closed from the keyboard.

  MICROWINDOWS.bat      Microwindows / Nano-X, from APRIL 2002. Kernel
                        2.4.18. Touchscreen. Logs in as "root" and starts
                        nanowm with an nxterm.

  TINYX-APRIL-2002.bat  Tinyx, from APRIL 2002. Kernel 2.4.18. Tinyx X
                        server, Matchbox and rxvt. Logs in as "root" and
                        starts the desktop.

  If you start X by hand in either Tinyx, do it from the console with
  startx & exit   (as the original Tinyx 0.6 README says). With plain
  startx   the text console left open repaints its palette over X's, and
  rxvt comes out blue with nearly invisible letters.

  TINYX-0.6.bat         Tinyx 0.6, from MAY 2002. Kernel 2.4.18, kept inside
                        the flash itself. Same as the previous one, a later
                        version. Logs in as "default" and starts the desktop.

  START-OVER.bat        Deletes the changes made inside the four systems and
                        puts each flash back the way it came. Asks first.

The date of each is the build date recorded in its kernel.

Each system reaches its desktop in one or two minutes: booting is the heavy
part and the emulator runs a little under real time there; after that it has
plenty to spare. The login and the start command are typed by a script on the
emulated infrared keyboard, as was done on the device. If you press any key
before it does, the script stays quiet and types nothing: the system is yours.


HOW TO USE IT
-------------

  Mouse            It is the touchscreen. A left click inside the window is
                   touching the screen with a finger at that point. PicoGUI
                   draws no pointer; Tinyx and Microwindows do.

  Keyboard         Everything you type goes to the TuxScreen's infrared
                   keyboard from the start.

  Scroll Lock      Switches between typing on the TuxScreen and using MAME's
                   keys. MAME says so on screen.

  Layout           MAME sends the physical key, so inside the TuxScreen your
                   keyboard works as a US one. Letters and digits come out
                   the same; symbols may not.

Text consoles: in Tinyx and Microwindows, Ctrl+Alt+F2 goes to a console with
a login. User "root", no password. It does not work in PicoGUI: PicoGUI keeps
the keyboard and the screen.


HOW TO SHUT DOWN WITHOUT DAMAGING ANYTHING
------------------------------------------

The flash is written as you go, but the clean way is to stop Linux before
closing the window.

Tinyx (both) and Microwindows:

  1. Press Ctrl+Alt+F2. Console 2 appears with "login:".
  2. Type root and press Enter.
  3. Type   sync   and press Enter.
  4. Type   halt   and press Enter.
  5. When "System halted." appears, close the MAME window.

PicoGUI:

  1. Press F1 (Applications opens) and then 7 (PicoGUI Terminal).
  2. In the terminal type   sync   and press Enter.
  3. Type   halt   and press Enter.
  4. PicoGUI closes and the screen goes BLACK.
  5. Wait ten seconds and close the MAME window.

THE BLACK SCREEN IS NOT AN ERROR, IT IS RIGHT. halt stops every program,
PicoGUI included, and when PicoGUI closes everything it drew goes away. In
the other systems you see "System halted." written; in PicoGUI you see
nothing because its kernel writes those messages on console 2, which is not
the one on screen. Underneath the same happens as in the other three: Linux
stops everything, unmounts the flash and stays halted. With the screen black
the flash is already safe.

What you will see at the end in Tinyx and Microwindows is this, and IT IS
RIGHT:

    # sync
    # halt
    Terminated
    # System halted.
    Kernel panic: Attempted to kill init!

THE "KERNEL PANIC" IS NOT AN ERROR. It always appears, and it is written by
the TuxScreen's own Linux, not by the emulator. These kernels do not know how
to power the phone off: they stop everything, unmount the flash, and since
they cannot cut the power they stay halted with that message. It is their
way of saying "you can switch off now". At that point the flash is safe and
the window can be closed without worry.

In April Tinyx and in Microwindows you can also type sync and halt in the
desktop's terminal, because there you are logged in as root. Tinyx 0.6 logs
in as "default", so use console 2 there.


WHERE YOUR CHANGES ARE KEPT
---------------------------

Each system's flash lives in state\<system>\tuxscreen\flash and is saved when
the window closes. The first time it is copied from flash-original\, which is
never touched. START-OVER.bat deletes the whole state\ folder.


WHAT IS NOT EMULATED
--------------------

  - Sound and the modem (the phone's DSP). The systems do not need them to
    boot or to be used.
  - The PCMCIA slots are empty: no network, no cards.
  - PicoGUI's progress screen, before the desktop, comes out with the wrong
    colours (green and purple). The desktop is right.


WHERE EACH THING COMES FROM
---------------------------

  - Images of the four systems: those of the original TuxScreen archive,
    untouched.
  - Boot loader: blob. Tinyx 0.6 uses the blob-20020709 from the archive;
    the other three use blob 2.0.5-pre2, built from its source code, because
    the 2002-07 one looks for the kernel inside the JFFS2 and those three
    keep it apart.
  - The emulator is MAME with a new driver for the TuxScreen and fixes in
    the StrongARM (wait for interrupt, infrared UART, serial UART) and in the
    UCB1200 codec (ADC interrupt and touchscreen).
