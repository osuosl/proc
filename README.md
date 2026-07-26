# proc — PROC-V1 remote management firmware

[![CI](https://github.com/osuosl/proc/actions/workflows/ci.yml/badge.svg)](https://github.com/osuosl/proc/actions/workflows/ci.yml)

Firmware for **PROC-V1**, a small board that gives a PC out-of-band management:
network-controlled power and reset buttons, and the machine's serial console
exposed over TCP. Roughly "poor man's IPMI" for hardware without a BMC.

An ATmega328PB drives a W5500 for wired Ethernet. You telnet to the board, get a
menu, and can power the host on or off, reset it, or drop into a transparent
serial console to talk to the BIOS, the bootloader or a Linux getty.

```
#DOC HTTPS://bjlx.org.cn/node/914
#Ver:PROC-V1-1.0.0-g4edb245
#name:PROC1A2B3C
#SN:28FF641E8016034A
#com:115200,8N1
#C1A2B3=23.50℃

======
0:com shell
r:reset (300ms)
R:reset (5 sec)
p:powerdown(300ms)
P:powerdown(5 sec)
v:Vout= ON
===set===
a:reboot          c:network info & modi     e:setpasswd
b:restore default d:com set                 f:modi script 1-9
q:quit offline
```

## Fork status

This is OSU Open Source Lab's maintained fork of
[`lshw/proc`](https://github.com/lshw/proc) by Liu Shiwei
(刘世伟, [bjlx.org.cn](https://bjlx.org.cn/)), who designed the hardware and wrote
the original firmware. **All credit for the design is his.** OSL runs several of
these boards and forked to fix bugs and add features, with the intent of sending
fixes back upstream.

What differs from upstream:

- **All Chinese text translated to English** — comments, README, build script.
  Comments only; the compiled image is byte-identical.
- **Bug fixes**, most importantly one where the telnet server went permanently
  deaf after abandoned sessions. See [CHANGELOG.md](CHANGELOG.md).
- **CI and releases** — every push is built and size-checked; tags produce
  signed-off `.hex` artifacts.
- **Documentation in English**, including translations of the vendor manuals.

Upstream remains Chinese, so expect conflicts on translated files when syncing.
The policy for that is in [CONTRIBUTING.md](CONTRIBUTING.md).

## Quickstart

**Build:**

```bash
./build.sh          # downloads arduino-cli into ~/bin if missing, writes ./prc.hex
```

`build.sh` writes to `$HOME`. For a contained build, or to reproduce exactly what
CI does, see [AGENTS.md §3](AGENTS.md#3-building).

**Flash** — from the managed host itself, or any machine with a USB serial adapter:

```bash
sudo systemctl stop getty@ttyS0      # free the port first
./update.sh                          # power the board as the countdown hits 1
```

The bootloader window is short; if it fails, retry with different timing. The
CONN3 "Update" jumper must be fitted so DTR can pull `/RESET`.

Prebuilt images are attached to each [release](https://github.com/osuosl/proc/releases).

**Connect:**

```bash
telnet <board-ip>        # default 192.168.1.2/24, no password
```

Set telnet to character mode first — see
[docs](doc/node-926-software-manual.md), which also covers getting a BIOS,
GRUB, kernel and getty console onto the serial port.

To reach the menu from the managed host's serial port instead, send
**six `+`, six `u`, then Enter**. (The vendor manual says seven of each; that
changed in 2024 and the manual was never updated.)

## Constraints worth knowing before you write code

- **Flash is nearly full.** ~29 KB of 30720 bytes. CI fails below 512 bytes free.
- **One `.ino`, ~1400 lines, no headers.** Cite `file:line` in reviews.
- **Not secure by design.** Cleartext telnet, numeric PIN, no TLS, and none of
  that is fixable on an ATmega328. Put these on an isolated management VLAN
  behind a jump host.
- **The DS18B20 is the device identity.** Its 1-Wire ROM code becomes the serial
  number, the MAC address and the default hostname.

## Documentation

| | |
|---|---|
| [AGENTS.md](AGENTS.md) | Deep technical reference — build, EEPROM map, menu, scripting, known issues |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Sign-off requirement, branch model, upstream sync policy |
| [CHANGELOG.md](CHANGELOG.md) | What changed, per release |
| [doc/node-926-software-manual.md](doc/node-926-software-manual.md) | Vendor software manual, translated and annotated |
| [osuosl/prc](https://github.com/osuosl/prc) | The hardware: schematic, PCB, BOM, pin map |

## License

GPL-3.0, inherited from upstream. See [LICENSE](LICENSE).
