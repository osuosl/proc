# AGENTS.md — `proc`: PROC-V1 production firmware

**This is the repository to change if the task is "improve the PROC software".**

Workspace overview: [../AGENTS.md](../AGENTS.md) · Hardware: [../prc/AGENTS.md](../prc/AGENTS.md)

**Last verified:** 2026-07-25 against `a8f458f` (2024-11-03), including an actual
`arduino-cli` build.

---

## 1. What this repo is

The firmware that runs on shipped PROC-V1 boards. One 1350-line Arduino sketch
plus two shell scripts. Upstream `lshw/proc`, GPL-3.0, 57 commits from
2020-01-02 to 2024-11-03, sole author Liu Shiwei.

> **Fork divergence:** in this fork the in-repo Chinese has already been
> translated in place — `README.md`, `build.sh`, and all 64 comment lines in
> `prc/prc.ino`. Upstream is still Chinese, so **expect conflicts on those
> files when rebasing on `upstream/main`**. The translation is one isolated
> commit and touches comments only: the compiled image is byte-identical apart
> from the embedded `__TIME__` literal, verified with `arduino-cli`.

Upstream README (now English in this fork):

> **proc** — source for proc_v1
>
> The IDE is Arduino; select model **Arduino Uno**. Connect the board's serial
> port to the computer and you can compile and download.
>
> To build from the command line: run `build.sh`, which uses `arduino-cli`. If
> `arduino-cli` is missing it downloads it; if libraries are missing the script
> downloads them. After compiling, the ROM lands in `prc.hex` in the same
> directory as `build.sh`.
>
> To upgrade from the command line: connect the device to a USB serial adapter.
> If you are upgrading from the managed machine itself, edit the script for the
> right serial device number, and under Linux make sure the serial `login`
> program has released the port. Run `update.sh`, then apply power to the device
> when the countdown reaches 1 and the upgrade begins. If it fails, adjust the
> timing of when you power the device and try again.

Note the README says "Arduino Uno" but `build.sh` actually builds for
**Arduino Pro / Pro Mini, ATmega328P 3.3 V 8 MHz**. Trust `build.sh`.

### Relationship to `../prc`

`prc` is the *hardware* repo. Its `control/control.ino` is an abandoned
prototype; this repo's first commit (`fc48b63`, 2020-01-02) is that same file,
and the two still differ by only 11 lines. All firmware development happened
here. The commit IDs in the released `.hex` images on the vendor site
(`d58845a`, `4b34ae9`) exist in *this* history's lineage, not in `prc`.

### Layout

| Path | What |
|---|---|
| `prc/prc.ino` | The entire firmware. 1350 lines, single translation unit |
| `build.sh` | `arduino-cli` wrapper. **Writes to `$HOME`** — see §3 |
| `update.sh` | `avrdude` wrapper with a 3-2-1 countdown |
| `README.md` | 14 lines, Chinese, translated above |
| `LICENSE` | GPL-3.0 |
| [doc/node-926-software-manual.md](doc/node-926-software-manual.md) | **English translation of the vendor software manual** (https://bjlx.org.cn/node/926), annotated with every point where it no longer matches this code. Added by OSL, not upstream |

Branches: `main` (default, current). `origin/public` is a stale 2021 divergence
— ignore it. Tags: `20230903-c0e3c26`, `20230907-3efd94e`, `v2024-11-03`
(the last points at `809b47f`, two commits behind `main`).

---

## 2. Commit history, translated

Newest first. This is the whole development arc of the product.

| Date | Commit | English |
|---|---|---|
| 2024-11-03 | `a8f458f` | Add fqbn compile parameter to CXXFLAGS |
| 2024-11-03 | `d95065d` | Build script can auto-install the toolchain and libraries, then compile |
| 2024-11-03 | `809b47f` | Sessions still authenticating must be cleaned up on timeout |
| 2024-11-03 | `c843fe0` | Enter the menu from the managed machine with six `+` and six `u` then Enter |
| 2024-11-03 | `bad3f8d` | Exit pass-through when switching client |
| 2024-11-02 | `8ac424e` | Rewrite the accept path: up to 3 remote clients may authenticate at once |
| 2024-11-02 | `ba2b018` | Move auth to connection setup; an authenticated new connection kicks the old one |
| 2024-11-02 | `6dbb189` | **Remove the PWM and autolink code** |
| 2024-11-02 | `10f183e` | Clean up code |
| 2024-11-02 | `4a0f1a7` | `+++++` from the serial side returns to the menu without auth; re-login only after disconnect |
| 2023-09-26 | `f9f900f` | Add PWM |
| 2023-09-07 | `3efd94e` | update.sh |
| 2023-09-07 | `98f04de` | RC clock calibration can only be started from the network side |
| 2023-09-07 | `eb0a2c4` | astyle |
| 2023-09-07 | `1ea18f3` | build.sh astyle |
| 2023-09-03 | `c0e3c26` | bootloader |
| 2023-09-02 | `968d9d1` | Fixed: a 0.6 s stall during the 60-second temperature read |
| 2023-09-02 | `0c188f3` | In DHCP mode, print nothing to the serial port at boot |
| 2023-09-02 | `ca4f739` | MAC address OUI bit is 0 |
| 2023-09-02 | `a5cecf4` | Show build time |
| 2023-09-02 | `1f39e46` | Build script passes `git_ver` to the compiler with `-D` |
| 2021-02-01 | `dcf0a1c` | Change the calibration range to ±80, check for overflow |
| 2021-03-12 | `ca983d9` | In DHCP mode too, don't send anything to serial at boot — avoid disturbing the PC's boot |
| 2021-01-07 | `42480d7` | Widen the calibration range |
| 2020-05-23 | `e5477f4` | Add `#define PWM` to configure whether PWM exists; add `#define AUTOLINK`; change the serial menu entry to 7×`+` then 7×`U` |
| 2020-05-20 | `1b047a7` | Drop the EEPROM checksum; ask for confirmation on factory reset |
| 2020-05-19 | `8530414` | Reset the network chip at boot |
| 2020-05-19 | `24c3281` / `4d9410b` | A new telnet connection can kick an old one in "bye" state |
| 2020-05-19 | `30daf30` | Add the degrees-Celsius symbol |
| 2020-05-11 | `9d51903` | Handle serial data for at most 2 seconds, then go check the network |
| 2020-04-25 | `d6b3875` | Clean up, tidy the display format |
| 2020-04-25 | `88de6f6` | Add scripting: 10 scripts, execution and configuration |
| 2020-04-25 | `604ffff` | Only set the output state once, when the countdown hits 0 |
| 2020-04-22 | `6e87179` | Add PWM test |
| 2020-02-27 | `0c37c0e` | Add a custom device name |
| 2020-02-27 | `ff16038` | Save initial values to EEPROM |
| 2020-02-27 | `dac1586` | Enlarge the buffer to 512 bytes |
| 2020-02-27 | `b2955c8` | A key press at boot can skip DHCP |
| 2020-02-27 | `58e2093` | Actively connect out to a remote server |
| 2020-02-27 | `0f6c29c` | Add active-outbound settings, usable when dhcp=y |
| 2020-01-21 | `4588c3a` | Firmware update script |
| 2020-01-20 | `472bc1e` | At most 11 temperature probes |
| 2020-01-19 | `7fd09ad` | Default 115200 bps; no password needed from the serial side |
| 2020-01-14 | `89882f7` | Exit quickly after TCP disconnect |
| 2020-01-11 | `24ba27e` | Rework the menu |
| 2020-01-09 | `c3188d0` | Change part of the watchdog setup |
| 2020-01-09 | `ba8750a` | Move directory |
| 2020-01-07 | `7690849` | Factory default 38400; add several calibrations for different serial speeds |
| 2020-01-05 | `62c5391` | ver 20200105 |
| 2020-01-05 | `4466ca0` | Basically complete, just the speed change left |
| 2020-01-03 | `2e27e55` | menu |
| 2021-03-12 | `9a924ed` | GPLv3 |
| 2020-01-02 | `fc48b63` | init |

---

## 3. Building

### The upstream way

```bash
./build.sh          # produces ./prc.hex
```

Be aware of what it does before you run it: `apt install` for `wget`/`git`,
downloads `arduino-cli` v1.0.4 into `~/bin`, `mkdir ~/Arduino`, `git clone`s
this repo into `~/Arduino/proc`, and installs libraries into
`~/Arduino/libraries`. Convenient on the author's machine, intrusive elsewhere.

### Contained equivalent

```bash
export ARDUINO_DIRECTORIES_DATA=/some/sandbox/data
export ARDUINO_DIRECTORIES_USER=/some/sandbox/user
arduino-cli core install arduino:avr
arduino-cli lib install OneWire Ethernet3

FQBN="arduino:avr:pro:cpu=8MHzatmega328"
VER="$(git log -1 --date=short --format=%ad | tr -d -)-$(git rev-parse --short=7 HEAD)"
arduino-cli compile --fqbn "$FQBN" \
  --build-property build.extra_flags="-DGIT_VER=\"$VER\" -DBUILD_SET=\"$FQBN\"" \
  prc
```

`arduino-cli` is not packaged in Debian; it is a GitHub release tarball.
Everything else the build needs (`avr-gcc`, `avrdude`, `astyle`) is installed.

### Facts

- **FQBN `arduino:avr:pro:cpu=8MHzatmega328`** — "Arduino Pro or Pro Mini,
  ATmega328P 3.3 V 8 MHz". The board carries a **328PB**, but nothing here
  touches PB-only peripherals, so the stock 328P core is used. The alternative
  `m328pb:avr:atmega328pbic` (from [../ATmega328PB](../ATmega328PB/AGENTS.md))
  is commented out in `build.sh` and is not what ships.
- **Libraries: `OneWire`** (Paul Stoffregen) and **`Ethernet3`** (W5500). The
  prototype in `../prc` used `Ethernet2` — do not confuse them.
- `GIT_VER` and `BUILD_SET` must come from the build. The `GIT_COMMIT_ID`
  fallback at the top of `prc.ino` is vestigial and never referenced.
- **Verified build at `a8f458f`** (arduino:avr 1.8.8, Ethernet3 1.6.0,
  OneWire 2.3.8): **29062 bytes flash (94% of 30720)**, 694 bytes globals
  (33% of 2048), 1354 bytes left for locals. The stale comment at the bottom of
  `build.sh` says 29078 — same ballpark, different library versions.
- **You have roughly 1.6 KB of flash headroom.** Check the `Sketch uses N bytes`
  line on every build; anything over 30720 will not fit.
- Formatter: `astyle` with `../procV2/lib/formatter.conf` (2-space indent,
  indented switches/cases, `pad-oper`, `pad-header`, `keep-one-line-statements`).
  Do not reformat the file — it makes rebases painful.

### Bootloader and fuses

From the comment block at the top of `prc.ino`, translated:

> The bootloader is based on "pro mini", with fuses H, L, E changed from
> FF, DA, FD to **C2, DA, FD** — from an external 8 MHz crystal to the internal
> 8 MHz RC. Write the Arduino IDE's ArduinoISP example into an Uno, then
> temporarily fit an 8 MHz crystal and wire `10 → reset` (the left pin of the
> "update" header), `11 → MOSI`, `12 → MISO`, `13 → CLK`, `GND → GND`,
> `VCC → 5Vin`. Choose programmer "Arduino as ISP", then Tools → Burn Bootloader.
>
> Compiling requires the OneWire library, maintainer Paul Stoffregen.

(The label order "H, L, E" is wrong; the values make it clear it is L, H, E.)
lfuse `0xC2` = CKSEL 0010, internal 8 MHz RC, CKDIV8 off — which is why the
crystal footprint on the board is unpopulated and why this firmware has to
calibrate `OSCCAL`. hfuse `0xDA` = a 2 KB boot section, hence the 30720-byte
application limit.

### Flashing

```bash
./update.sh
# or directly:
avrdude -v -patmega328p -carduino -P/dev/ttyUSB0 -b57600 -D -Uflash:w:prc.hex:i
```

The bootloader window is short, so `update.sh` counts down 3-2-1 and you apply
power to the board as it reaches 1. If it fails, retry with different timing.

For this to work the **CONN3 "Update" jumper must be closed** so the adapter's
RTS/DTR can pull the MCU's `/RESET` — see [../prc/AGENTS.md](../prc/AGENTS.md)
§6.4. Leave it open in normal service so the managed PC cannot reset the
controller.

If flashing from the managed machine itself, stop whatever `getty` holds the
port first.

---

## 4. Firmware reference

All line numbers refer to `prc/prc.ino` at `a8f458f`.

### 4.1 Structure

There are no headers; it is one flat sketch. Rough map:

| Lines | Area |
|---|---|
| 1–160 | Pin defines, EEPROM enum, globals, `eeprom_read/write` helpers |
| 163–222 | `setup()` — identity, EEPROM validation, serial, DHCP/static network |
| 223–247 | `magic()` — the serial escape-sequence state machine |
| 260–334 | `new_link()` — accept + authenticate up to 3 pending TCP clients |
| 336–359 | `loop()` |
| 361–404 | `com_shell()` — the serial pass-through |
| 406–459 | `ISR(WDT_vect)` 30 ms tick + `setup_watchdog()` |
| 462–604 | `menu()` |
| 605–708 | DS18B20 enumeration, conversion, display |
| 709–795 | `check_rom()` — EEPROM validation and factory defaults |
| 796–822 | `set_passwd()` |
| 825–916 | `rc_calibration()` |
| 918–1019 | `info()` / `save_set()` — network settings menu |
| 1020–1136 | Serial-parameter get/set |
| 1157–1227 | `getc_()`, `hello()` banner, string entry |
| 1228–1349 | Script engine: `run_script()`, `modi_script()`, `disp_script()` |

### 4.2 EEPROM layout

All accesses go through `eeprom_read()`/`eeprom_write()`, which add
`EEPROM_OFFSET = 12` — so index 0 below is physical EEPROM address 12.
`eeprom_write()` skips writes when the value is unchanged (wear reduction).

| Symbol | Bytes | Contents |
|---|---|---|
| `CAL38400`, `CAL57600`, `CAL115200`, `CAL230400` | 4 | Per-baud `OSCCAL` calibration values |
| `VOUT_SET` | 1 | Saved VOUT state, restored at boot |
| `MAC0..MAC5` | 6 | MAC. `MAC0..2 == DC AD BE` doubles as the "settings are valid" magic |
| `IS_DHCP` | 1 | `'Y'` / `'N'` |
| `IP0..3`, `NETMARK0..3`, `GW0..3` | 12 | Static network config |
| `SPEED0..3` | 4 | Baud rate, big-endian u32 |
| `DATA_LEN`, `DATA_PARI`, `STOP_LEN` | 3 | `'5'`–`'8'`, `'N'/'O'/'E'`, `'1'/'2'` |
| `PASSWD0..3` | 4 | Numeric password, big-endian u32. `0` = none |
| `SN0..SN8` | 9 | DS18B20 ROM code = device serial number |
| `NAME0..NAME10` | 11 | Device name, NUL-terminated |
| `WATCHDOG0..10`, `WATCHDOG_EN` | 12 | **Defaults are written; nothing ever reads them.** Unfinished |
| `PWM_NOW` | 1 | Last PWM value |
| `ROMCRC` | 1 | End of the checked region; the CRC itself was dropped in 2020 (`1b047a7`) |
| `REMOTE_CYCLE`, `REMOTE_PORT_H/L`, `REMOTE_HOST` | 4+ | **Dead** since `6dbb189` |
| scripts | 10 × 50 | From `SCRIPT_ADDR = ROMLEN + 2`; script *n* at `+50n`. Slot 0 exists but only 1–9 are reachable |

Factory defaults (`check_rom()`): IP `192.168.1.2`, mask `255.255.255.0`,
gateway `192.168.1.1`, DHCP off, 115200 8N1, no password, name `PROC<hex>`,
VOUT on, PWM 128, scripts cleared.

### 4.3 Identity — the DS18B20 is the serial number

On first boot the firmware enumerates the 1-Wire bus; if exactly one probe is
present its 64-bit ROM code becomes the device serial number (`SN0..SN7`), the
MAC becomes `DC:AD:BE:<SN[5]>:<SN[6]>:<SN[7]>`, and the default name becomes
`PROC` + those three bytes in hex. The on-board DS18B20 (D3 on the PCB) is
therefore what makes each unit unique. See §5 issues 5 and 6 for what goes
wrong when it is absent, and issue 15 for the OUI problem.

### 4.4 RC-oscillator calibration

The MCU runs from the internal 8 MHz RC oscillator (±10% from the factory),
which is not accurate enough for 115200 baud. The firmware stores a separate
`OSCCAL` trim per baud rate and applies it at boot.

Menu key `z`/`Z` runs `rc_calibration()` — **network logins only, and only
within the first 200 s of uptime** (line 566). It sweeps `OSCCAL` over ±80 while
you hold `U` on the serial console, finds the range where the character still
decodes, takes the midpoint, and stores it.

Practical consequence: **switching to a baud rate that was never calibrated can
leave the serial link unreadable until you run `z` again.**

### 4.5 Menu

```
======
0:com shell              (network sessions only)
r:reset (300ms)
R:reset (5 sec)
p:powerdown(300ms)
P:powerdown(5 sec)
V:Vout= ON               <- shown as 'V', but only lowercase 'v' works (issue 3)
<,.> :PWM=128            (PWM builds only, which do not compile — issue 1)
===script 1-9====
...
===set===
a:reboot
b:restore default set
c:network info &  modi
d:com set
e:setpasswd
f:modi script 1-9
n:change name:PROC1A2B3C <- also fires a 300 ms PC reset (issue 2)
q:quit offline
```

Hidden: `z`/`Z` = RC calibration. Idle timeout 20 s per keystroke (`getc_()`),
then the session drops.

Connect banner (`hello()`, values illustrative):

```
#DOC HTTPS://bjlx.org.cn/node/914
#Ver:PROC-V1-20241103-a8f458f
#Buile Set:'arduino:avr:pro:cpu=8MHzatmega328'    <- "Buile" is an upstream typo
#Build Time:2024-11-03 10:22:31
#name:PROC1A2B3C
#SN:28FF641E8016034A
#com:115200,8N1
#C1A2B3=23.50℃
```

### 4.6 Script language

Menu `f`, then pick 1–9. Max 50 characters per script. From the
[vendor manual](doc/node-926-software-manual.md) cross-checked against
`run_script()`:

| Cmd | Meaning |
|---|---|
| `P` | Press power. Optional following number (1–65536) = hold in ms. **Non-blocking** |
| `p` | Release power |
| `R` | Press reset. Optional number = hold in ms. **Non-blocking** |
| `r` | Release reset |
| `V` | Turn the 5–28 V output on. With a number, `analogWrite()` that value |
| `v` | Turn the output off |
| `T`/`t` | Followed by a number: wait that many ms. **Blocking** |
| `M` | Documented as "set PWM 0–255" — **not implemented in `run_script()`** |

### 4.7 Sessions, authentication, escape sequences

- TCP port **23**. One active session plus up to **3** in the auth queue
  (`clientn[3]`).
- Password is a decimal number in a `uint32_t`. Default `0`, so pressing Enter
  logs you in. 20 s to enter it; wrong → 5 s penalty, then disconnect.
- A newly authenticated client **kicks the current one**
  ("new client up, you are offline.").
- **Serial → menu:** six `+`, then six `u`/`U`, then Enter (lines 224–247).
- **Pass-through → menu:** at least five `+` immediately followed by Enter
  (lines 380–388).
- While no client is connected, incoming serial data is **read and discarded**
  (lines 355–358). There is no scrollback buffer.

### 4.8 Timing / watchdog

The watchdog runs as a 30 ms **interrupt** (`WDIE`, not `WDE`) and doubles as
the system tick:

- `pc_reset_on` / `pc_power_on` are millisecond counters. Any code can write
  `pc_reset_on = 300` and the ISR holds the line for 300 ms then releases it.
  This is how non-blocking script commands work.
- `dogcount` is cleared by the main loop; at 100 s the ISR does `jmp 0`.
- Temperature is re-read every 60 s (`timer1`).

---

## 5. Verified issues and improvement targets

Read by inspection at `a8f458f`; items marked **verified by build** were
reproduced with `arduino-cli`.

> **These are tracked as GitHub issues** — <https://github.com/osuosl/proc/issues>.
> This table keeps the analysis; the issues carry the state. Update both, or
> delete the row here and let the issue own it.
>
> | Here | Issue | | Here | Issue |
> |---|---|---|---|---|
> | 0 | **fixed** — see §5.1 | | 8 | [#7](https://github.com/osuosl/proc/issues/7) |
> | 1 | **fixed** | | 9 | [#8](https://github.com/osuosl/proc/issues/8) |
> | 2 | [#1](https://github.com/osuosl/proc/issues/1) | | 10 | [#9](https://github.com/osuosl/proc/issues/9) |
> | 3 | [#2](https://github.com/osuosl/proc/issues/2) | | 11 | [#10](https://github.com/osuosl/proc/issues/10) |
> | 4 | [#3](https://github.com/osuosl/proc/issues/3) | | 12 | [#11](https://github.com/osuosl/proc/issues/11) |
> | 5 | [#4](https://github.com/osuosl/proc/issues/4) | | 13 | [#12](https://github.com/osuosl/proc/issues/12) |
> | 6 | [#5](https://github.com/osuosl/proc/issues/5) | | 14 | [#13](https://github.com/osuosl/proc/issues/13) |
> | 7 | [#6](https://github.com/osuosl/proc/issues/6) | | 15 | [#14](https://github.com/osuosl/proc/issues/14) |
>
> Also filed, not in the table below:
> [#15 — clear the 28 compiler warnings](https://github.com/osuosl/proc/issues/15).

| # | Severity | Issue |
|---|---|---|
| 0 | **Critical — FIXED on this branch** | **The telnet server goes permanently deaf after abandoned sessions.** `new_link()` returned at line 269 whenever `server.available()` yielded no client — but Ethernet3's `EthernetServer::available()` only returns a socket that has **unread bytes waiting** (`EthernetServer.cpp:60`), and the pending-slot timeout handling lives *inside* the loop after that return. So three abandoned sessions (closed terminal, dropped tunnel) left all three `clientn[]` slots stuck in `proc == 1` with nothing ever reclaiming them, and every later connection was accepted by the W5500 but never given a slot: TCP connects, no `passwd:` prompt, silence until the client gives up. Contributing factors: `clientn[i].ms < millis()` breaks across the ~49-day rollover, and the W5500 accepts up to 7 connections while the firmware tracks 4, with no keepalive configured (`Sn_KPALVTR` is never written) so stale sockets survive indefinitely — a link flap does **not** clear them. See §5.1 |
| 1 | **High** | **PWM builds do not compile.** `uint8_t pwm;` (line 28, inside `#ifdef PWM`) and `uint8_t pwm = 128;` (line 461) are both namespace-scope definitions. **Verified by build:** `-DPWM=5` fails with `error: redefinition of 'uint8_t pwm'`. Dead since the 2024 cleanup |
| 2 | **High** | **Renaming the device presses the PC's reset button.** `case 'n'`/`'N'` (lines 532–535) has no `break` and falls into `case 'r'` (line 536), which sets `pc_reset_on = 300` |
| 3 | Medium | **Menu advertises `V` but only `v` works.** Menu prints `"V:Vout= "` (line 488); the only handler is `case 'v'` (line 548). The `case 'V'` at line 1266 is in `run_script()`, not the menu |
| 4 | Medium | **1-Wire CRC check reads out of bounds.** `OneWire::crc8(addr, 8) != addr[8]` (line 664) where `addr = ds_addr[n]` and `ds_addr` is `[11][8]` — `addr[8]` is the first byte of the *next* probe's ROM code. Should be `crc8(addr, 7) != addr[7]`. Healthy probes can be silently marked dead (`celsius[n] = -400*16`), or bad ones accepted |
| 5 | Medium | **A unit with no valid DS18B20 factory-resets on every boot.** `check_rom()` sets `sets[MAC2] = 0` when no valid ROM ID is available (line 732), but the "settings valid" early exit requires `MAC2 == 0xBE` (line 716). Every boot then rewrites IP, password, baud and scripts back to defaults. Production boards have D3 fitted so this normally does not fire — but a failed probe turns the unit into a factory-reset-on-boot device |
| 6 | Low | **`if (ds_addr[0] != 0)` (line 739) is always true** — it compares an array to 0. The `else` branch assigning the fallback MAC `…:00:01:25` is dead code |
| 7 | **Design** | **Auth is a numeric PIN over cleartext telnet, tested on every keystroke** (lines 280–296). Default `0`. A password that is a numeric prefix of what you type matches early; the accumulator can overflow `uint32_t`; the only penalty is 5 s and there is no source filtering. Not meaningfully fixable on an ATmega328 — treat these as management-VLAN-only appliances behind a jump host |
| 8 | Medium | **`com_shell()` drops every byte ≥ 0xF4 network→serial** (line 379), a crude telnet-IAC filter. Binary transfers toward the host (XMODEM/Kermit, pasted binary) corrupt silently |
| 9 | Medium | **Escape sequences no longer match the published manual.** Serial→menu is 6 `+` then 6 `u`/`U` then Enter; the manual says 7 and 7, and a 7th `+` permanently breaks the match until a non-matching character resets `magic_flag`. Pass-through→menu needs ≥5 `+` immediately before Enter, while the firmware's own banner says `+++` (line 368) |
| 10 | Medium | **Autolink (dial-out) removed in 2024** by `6dbb189`. `REMOTE_CYCLE` / `REMOTE_PORT_H/L` / `REMOTE_HOST` still occupy EEPROM (lines 133–136, 787–790); nothing reads them, no menu entry exists, and the vendor manual still documents the feature. **This is the code to restore if OSL needs to reach boards with no inbound route** — `git show 6dbb189` is the deleted implementation |
| 11 | **Opportunity** | **The `WATCHDOG*` EEPROM slots (lines 118–129, 779–786) are defaults-only.** The comments describe a recovery sequence (`r` reset, `w` wait, `P` power 5 s, `o`/`O` Vout off/on) that no code implements. For a colo fleet this is the highest-value feature to build: a board that power-cycles a wedged host by itself |
| 12 | Medium | **"Reboot" is `jmp 0`, not a reset.** `setup_watchdog()` enables `WDIE` but not `WDE` (lines 447–459); the 100 s timeout (lines 412–415) and menu `a` (lines 581–582) both jump to address 0 without resetting peripherals or the W5500. A wedged peripheral survives. Switching to a real WDT reset is a small, high-value patch |
| 13 | Low | **`../prc/README.md` claims 32 temperature probes; this firmware supports 10.** `celsius[11]` / `ds_addr[11][8]` with slot 0 reserved for the identity probe (lines 24, 58) |
| 14 | **Constraint** | **~1.6 KB of flash left** (29062/30720). RAM: 694 B globals plus a 512 B stack buffer in `com_shell()` (line 362) and a 256 B `oscs[]` in `rc_calibration()` (line 827) that is written but never read — 256 free bytes right there. `ds1820_disp()` pulls in floating-point `print`; fixed-point would free noticeably more |
| 15 | Low | **MAC OUI `DC:AD:BE` has the locally-administered bit clear**, claiming a globally-unique OUI the project does not own. `DE:AD:BE` would be correct. Commit `ca4f739` shows the author was aware of the OUI bit |

### 5.1 The `new_link()` deafness fix

Four changes, all in `new_link()`, costing **48 bytes** of flash (29062 → 29110,
still 94%, 1610 free) and no RAM:

1. **Removed the early return**, folding `host.connected()` into the `have_new`
   condition, so the pending-slot state machine runs on every call rather than
   only when some socket happens to hold data. This is the actual bug.
2. **Reclaim a slot the moment its peer disconnects**, instead of waiting out
   the 20 s timeout. `EthernetClient::connected()` stays true in `CLOSE_WAIT`
   while bytes remain, so a password typed just before the FIN is still read.
3. **Rollover-safe deadlines** via `ms_expired()`, comparing the signed
   difference. The `clientn[i].ms = 0` sentinel became `millis() - 1`, since
   `0` is not "already expired" under signed-delta arithmetic.
4. **Refuse connections when every slot is busy** (`busy`, then `stop()`)
   instead of leaving them accepted but unread. `server.available()` always
   returns the *lowest* socket holding data, so one unread orphan masks every
   later connection.

Walking the original failure through the patched code: a closed terminal puts
the socket in `CLOSE_WAIT` with no data, `server.available()` returns nothing,
`host` is invalid and `have_new` is false — but the loop now still runs, case 1
sees `!connected()` and frees the slot on the very next iteration.

Operational notes for anyone debugging a wedged unit before this is deployed:

- **Bouncing the switch port does not help.** No keepalive is configured, and
  nothing in the sketch monitors PHY link state or re-inits the chip after
  `setup()`, so stale sockets survive a link flap unchanged.
- **The serial escape still works** — it runs through `magic()` in `loop()`,
  independent of the TCP path — *provided* `alreadyConnected` is false, since
  `menu(S_SERIAL)` is gated on it.
- **Prefer the menu's `a` reboot over S1 or a power cycle.** `a` is `jmp 0`,
  which does not reset the I/O registers, so PD3 holds its state and VOUT stays
  up. A real reset drops VOUT for about a second (R17 pulls Q1's gate down,
  R7 pulls the P-FET gates to VIN), which power-cycles anything fed from it.
- `EthernetClient::stop()` blocks for up to 1 s waiting for the socket to close,
  so each reclaim can stall the loop that long. Far below the 100 s watchdog,
  and it happens once per disconnect.

### Suggested order of work

1. Issues 2, 3, 4 — small, obviously correct, upstreamable as one series.
2. Issue 1 — fix or delete the `#ifdef PWM` path outright if OSL's boards have
   no PWM pad.
3. Issue 12 — a real watchdog reset makes the fleet self-healing.
4. Issue 11 — the host watchdog. This is the feature that pays for itself.
5. Reclaim flash (issue 14) to pay for the above.
6. Decide the security posture (issue 7): network isolation now; `../procV2` or
   a Linux-side front-end (`conserver`, `ser2net`) later.
7. Optional: restore autolink (issue 10) for hosts with no inbound route.

---

## 6. Conventions

- **Cite `file:line`.** One 1350-line file with no headers; line references are
  how anyone else finds what you mean.
- **Do not reformat.** `astyle` with `../procV2/lib/formatter.conf`, and only on
  lines you actually touch.
- **Check the flash number on every build.** Over 30720 bytes will not fit.
- **Do not change pin defines** without changing the hardware — the mapping is
  fixed by the PCB. See [../prc/AGENTS.md](../prc/AGENTS.md) §6.2.
- **Write commit messages in English** in an OSL fork; add a Chinese subject
  line if you intend to send the patch upstream.
- Upstream releases by tagging `YYYYMMDD-<short-sha>`; the newest tag is not
  necessarily HEAD.
