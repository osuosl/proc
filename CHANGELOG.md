# Changelog

**This file is maintained by [release-please](https://github.com/googleapis/release-please).**
Do not edit the generated sections by hand — write
[conventional commits](CONTRIBUTING.md#commit-messages) and they will appear
here on the next release.

The version is compiled into the firmware and shown in the telnet banner as
`#Ver:PROC-V1-<version>-g<sha>`, so a banner read off a deployed board maps to an
exact commit.

<!-- release-please inserts new versions directly below this line -->

## Fork baseline

Context for everything above, written by hand before release automation existed.

OSU OSL's fork of [`lshw/proc`](https://github.com/lshw/proc) by Liu Shiwei,
who designed the hardware and wrote the firmware. Fork point is
[`a8f458f`](https://github.com/lshw/proc/commit/a8f458f) (2024-11-03). Upstream
keeps no changelog; its history is in `git log`.

The fork exists because OSL runs several of these boards and hit a bug in
production. Two fixes landed before automation:

- **The telnet server went permanently deaf after abandoned sessions.**
  `new_link()` returned early whenever `server.available()` yielded no client,
  but Ethernet3 only returns a socket with *unread bytes waiting*, and the
  pending-slot timeout handling lived after that return. Three abandoned
  sessions pinned all three authentication slots forever; every later connection
  was accepted by the W5500 but never given a slot, so telnet connected and then
  sat silent until it timed out. Only a reboot cleared it.
- **`-DPWM=5` had been unbuildable since 2024** — `pwm` was defined twice at
  namespace scope.

Also in the baseline: all Chinese text translated to English (comments only —
the compiled image is byte-identical apart from the embedded `__TIME__`), the
vendor manuals translated under `doc/`, `AGENTS.md` as a technical reference,
and CI covering both build variants with a flash-headroom gate.

**Nothing in the baseline was tested on hardware.** The `new_link()` fix in
particular wants a real node before it is trusted in a release.
