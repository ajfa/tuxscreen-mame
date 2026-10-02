#!/usr/bin/env python3
"""Run the tuxscreen driver without a window and drive its serial console.

usage: console.py [options] [expect send]...

Each pair waits for EXPECT on the console, then types SEND followed by Enter.
Everything the console prints goes to --log. Exit status 0 when every EXPECT
was seen (and --final, if given), 1 otherwise.
"""
import argparse
import os
import re
import select
import subprocess
import sys
import termios
import time
import tty


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mame", required=True, help="tuxscreen binary")
    ap.add_argument("--rompath", required=True)
    ap.add_argument("--run", required=True, help="working folder (nvram, cfg, logs)")
    ap.add_argument("--seconds", type=int, default=300, help="emulated seconds")
    ap.add_argument("--log", required=True)
    ap.add_argument("--final", help="text that must appear after the last step")
    ap.add_argument("steps", nargs="*")
    a = ap.parse_args()
    steps = list(zip(a.steps[0::2], a.steps[1::2]))

    os.makedirs(a.run, exist_ok=True)
    errlog = os.path.join(a.run, "error.log")
    if os.path.exists(errlog):
        os.remove(errlog)
    env = dict(os.environ)
    for k in ("DISPLAY", "WAYLAND_DISPLAY", "XDG_SESSION_TYPE"):
        env.pop(k, None)
    env["SDL_VIDEODRIVER"] = "dummy"
    env["SDL_AUDIODRIVER"] = "dummy"
    cmd = [a.mame, "tuxscreen", "-rompath", a.rompath,
           "-nvram_directory", os.path.join(a.run, "nvram"),
           "-cfg_directory", os.path.join(a.run, "cfg"),
           "-snapshot_directory", os.path.join(a.run, "snap"),
           "-serial", "pty", "-video", "none", "-sound", "none", "-skip_gameinfo",
           "-nothrottle", "-log", "-seconds_to_run", str(a.seconds)]
    mame = subprocess.Popen(cmd, cwd=a.run, env=env, stdout=open(os.path.join(a.run, "mame.out"), "wb"),
                            stderr=subprocess.STDOUT)

    pts = None
    deadline = time.time() + 60
    while pts is None and time.time() < deadline and mame.poll() is None:
        time.sleep(0.2)
        if os.path.exists(errlog):
            m = re.search(r"serial on (/dev/pts/\d+)", open(errlog, errors="replace").read())
            if m:
                pts = m.group(1)
    if pts is None:
        print("no serial pty; mame exit %s" % mame.poll())
        mame.kill()
        return 1

    fd = os.open(pts, os.O_RDWR | os.O_NOCTTY)
    tty.setraw(fd)
    attrs = termios.tcgetattr(fd)
    attrs[4] = attrs[5] = termios.B115200
    termios.tcsetattr(fd, termios.TCSANOW, attrs)

    out = open(a.log, "wb")
    seen, step, final_seen = b"", 0, a.final is None
    while mame.poll() is None:
        if os.path.getsize(errlog) > 200 * 1024 * 1024:
            mame.kill()
            break
        r, _, _ = select.select([fd], [], [], 0.2)
        if r:
            try:
                data = os.read(fd, 4096)
            except OSError:
                break
            out.write(data)
            out.flush()
            seen += data
        if step < len(steps) and steps[step][0].encode() in seen:
            seen = b""
            for ch in steps[step][1] + "\r":
                os.write(fd, ch.encode())
                time.sleep(0.05)
            step += 1
        if step == len(steps) and not final_seen and a.final.encode() in seen:
            final_seen = True
            mame.terminate()
    mame.wait()
    out.close()
    ok = step == len(steps) and final_seen
    print("steps %d/%d%s" % (step, len(steps), "" if a.final is None else ", final %s" % final_seen))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
