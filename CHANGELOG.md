# Changelog

Notable changes to OSU OSL's fork of [`lshw/proc`](https://github.com/lshw/proc).
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning is [SemVer](https://semver.org/).

The version is compiled into the firmware and shown in the telnet banner as
`#Ver:PROC-V1-<version>-g<sha>`, so a banner read off a deployed board maps to an
exact commit.

## [Unreleased]

### Fixed

- **The telnet server no longer goes permanently deaf after abandoned sessions.**
  `new_link()` returned early whenever `server.available()` yielded no client,
  but Ethernet3 only returns a socket that has *unread bytes waiting*, and the
  pending-slot timeout handling lived after that return. Three abandoned
  sessions — a closed terminal, a slept laptop, a dropped tunnel — pinned all
  three authentication slots forever, and every later connection was accepted by
  the W5500 but never given a slot: TCP connects, no `passwd:` prompt, silence.
  Only a reboot cleared it. Also: slots are now reclaimed the moment a peer
  disconnects rather than after the full 20 s timeout; deadlines survive the
  ~49-day `millis()` rollover; and a connection arriving with every slot busy is
  refused with `busy` instead of being left accepted but unread, where it would
  mask every later connection. (+48 bytes flash)
- **`-DPWM=5` builds compile again.** `pwm` was defined twice at namespace
  scope, which is a hard error in C++, so the PWM variant had been unbuildable
  since the 2024 cleanup. Also removed the unused `vout` global. (−42 bytes
  flash in the stock build)

### Changed

- **All Chinese text translated to English** — every comment in `prc/prc.ino`,
  the messages and comments in `build.sh`, and `README.md`. Comments only: the
  compiled image is byte-identical apart from the embedded `__TIME__` literal.
- `README.md` rewritten for a maintained fork.

### Added

- **CI** — both build variants, pinned toolchain, flash-headroom gate at 512
  bytes free, size-delta reports on PRs, compiler-warning reports, downloadable
  firmware artifact per commit.
- **Release pipeline** — tagging `vX.Y.Z` builds both variants and attaches
  `.hex`, `.elf`, `SHA256SUMS` and `toolchain.txt`.
- `AGENTS.md` — technical reference: build, EEPROM layout, menu, scripting,
  session handling, and the verified issue list.
- `doc/node-926-software-manual.md` — the vendor software manual translated and
  annotated wherever it no longer matches the code.
- `CONTRIBUTING.md`, this changelog, and `tools/` (vendored astyle config from
  `lshw/procV2`, plus `format.sh`).

### Known issues

Tracked at <https://github.com/osuosl/proc/issues>. The ones to know about:

- Menu option `n` (change name) falls through and fires a 300 ms reset at the
  managed host.
- The menu prints `V:Vout=` but only lowercase `v` is handled.
- `ds1820()` reads one byte past the end of an 8-byte ROM code.
- A board whose DS18B20 has failed factory-resets on every boot.
- The `WATCHDOG*` EEPROM slots are written but never read — the host watchdog
  they describe was never implemented.
- Authentication is a numeric PIN over cleartext telnet. Not fixable on this
  MCU; treat these as management-VLAN-only appliances.

---

Upstream history before the fork is in `git log`; upstream does not keep a
changelog. The fork point is
[`a8f458f`](https://github.com/lshw/proc/commit/a8f458f) (2024-11-03).
