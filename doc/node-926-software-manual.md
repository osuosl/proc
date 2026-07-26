# PROC Software Instructions

> **English translation of** https://bjlx.org.cn/node/926
> Original title: **proc软件使用说明**
> Author: 刘世伟 (Liu Shiwei) · Published Sunday, 2020-04-26 19:48
> Site: 北京龙芯＆debian用户俱乐部 (Beijing Loongson & Debian User Club)
>
> Translated 2026-07-25. Editorial notes added by the translator are marked
> **[Note]** and are not part of the original.

**Companion page:** [Hardware installation manual](https://github.com/osuosl/prc/blob/main/doc/node-914-hardware-manual.md)
(original: https://bjlx.org.cn/node/914)

> ⚠ **This page documents the firmware as of 2020.** Several details no longer
> match upstream HEAD (`a8f458f`, 2024-11-03). Every divergence found is marked
> **[Note]** inline. The current behaviour is documented in
> [../AGENTS.md](../AGENTS.md).

---

PROC can control a PC's reset button and power button over the network, for
remote power on/off and remote restart. It can also enter the serial port and
interact with the BIOS, the bootloader and the Linux console, to complete OS
installation, network configuration, fault recovery, remote maintenance and so
on.

## Getting in

PROC (PC remote operation controller) has a default IP of **192.168.1.2/24**.
For initial setup you can log in over the serial port, or configure your
computer onto that subnet and `telnet 192.168.1.2` to log in.

**There is no password by default.** You can set one; the password applies only
to network logins.

### Logging in over serial

```
minicom -D /dev/ttyS0 -b 115200 -R utf-8
```

Then type **seven `+` and seven `U`** followed by Enter. If there is no
response, PROC may be busy doing DHCP — wait 30 seconds and type the seven `+`
and seven `U` and Enter again.

> **[Note]** Upstream HEAD requires **six** `+` and **six** `u`/`U`, then Enter.
> Worse, typing a seventh `+` jams the matcher until a non-matching character
> resets it, so following this page literally will not work on current firmware.
> See [../AGENTS.md](../AGENTS.md) §5 issue 9.

### Logging in over the network

Set telnet to use character mode by default; in the default line mode nothing is
sent until you press Enter.

Create `~/.telnetrc` containing the following three lines. The first line must
have no leading space; the other two must be indented:

```
default
  mode character
  set binary
```

Then:

```
telnet 192.168.1.2
```

Besides telnet you can also use PuTTY to connect over the network.

When logging in over serial you must first type `+++++++UUUUUUU` and Enter
before you get a response. This is to stop the serial output during PC boot from
interfering with the boot process.

## The menu

After logging in the main menu appears. Its contents are very simple:

- **`0`** enters serial pass-through
- **`r`, `R`, `p`, `P`** — four keys controlling the PC's power switch and reset
- If the PWM option is fitted, **`<`, `,`, `.`, `>`** control the PWM output
- **`1`–`9`** are user-defined scripts. Script definition is documented on a
  separate page …

There are also functions to configure the network, set the password, configure
the serial port, edit scripts, restore factory settings, and reboot.

> **[Note]** The menu also prints `V:Vout=` but only lowercase `v` toggles the
> output, and `n` (change name) also fires a 300 ms PC reset. See
> [../AGENTS.md](../AGENTS.md) §5 issues 2 and 3. Exiting pass-through back to
> the menu takes **five or more** `+` immediately followed by Enter, despite the
> firmware's own banner saying `+++`.

## Active outbound mode (autolink)

After setting the network to DHCP mode you can enable **active outbound mode**
to work around not having a public IP or a VPN.

In active outbound mode you can configure a remote server — an IP address or a
domain name both work. PROC will periodically connect to that server's port; on
the server you only need to listen with `nc` or `socat` to reach PROC's menu,
control the computer, and log in over the serial port.

> **[Note] This feature no longer exists.** It was deleted from the firmware on
> 2024-11-02 by commit `6dbb189` ("清理pwm和autolink代码"). The EEPROM fields
> remain but nothing reads them and there is no menu entry. `git show 6dbb189`
> recovers the implementation. See [../AGENTS.md](../AGENTS.md) §5 issue 10.

---

That covers using PROC, which is fairly simple. Next, how to use the serial port.

## Serial console setup on the managed machine

### Redirecting BIOS output to the serial port

This requires motherboard support and is configured in the BIOS, for example:

```
Server Management --> Console Redirection --> Console Redirection = "Serial Port A"
```

### Getting PMON output on the serial port

This needs no configuration at all — PMON supports serial operation directly.
The `boot.cfg` menu is simply not drawn, but keyboard input still works.

LoongArch motherboard firmware will output on the serial port as long as no
monitor is plugged in. However, release builds generally do not include serial
support, so you need a `dbg` build of the firmware.

### Redirecting GRUB 1 output to the serial port

Edit `/boot/grub/menu.list`:

```
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
```

### Redirecting GRUB 2 output to the serial port

Edit `/etc/default/grub` or `/etc/default/grub.d/serial.cfg`:

```
GRUB_TERMINAL="serial console"
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty"
```

### Kernel boot messages on the serial port

Modify the GRUB configuration to add this to the kernel command line:

```
console=ttyS0,115200n8 console=tty0
```

### Logging into a Linux shell over the serial port

On non-systemd systems, edit `/etc/inittab`, add the following, then `kill -1 1`
to make init reload its configuration file:

```
T0:23:respawn:/sbin/getty -L ttyS0 115200 vt100
```

On systemd systems:

```
systemctl start getty@ttyS0
systemctl enable getty@ttyS0
```

---

## PROC script configuration

From PROC's main menu, press **`f`** to enter script configuration, then choose
which script to modify (**1–9**).

Each script can be at most **50 characters**. The command format is:

| Command | Meaning |
|---|---|
| `P` | Press the power switch. May be followed by a number (1–65536) giving how many ms to hold it. The delay is **non-blocking** — the following commands execute immediately |
| `p` | Release the power switch |
| `R` | Press the reset button. May be followed by a number (1–65536) giving how many ms to hold it. The delay is **non-blocking** — the following commands execute immediately |
| `r` | Release the reset button |
| `V` | Turn the (5–28 V) output on |
| `v` | Turn the (5–28 V) output off |
| `M` | Followed by a number (0–255): set the PWM output |
| `T` | Followed by a number (1–65536): wait this many ms. **Blocking** — the following commands only execute once the delay finishes |

> **[Note]** In upstream HEAD, `run_script()` implements `P p R r V v` and
> `T`/`t`, but **not `M`**. `V` with a numeric argument does an `analogWrite()`
> rather than a plain on. The "separate page" promised above for script
> documentation is this section — no other page exists.

---

## Attachments on the original page

| File | Size | URL |
|---|---|---|
| Firmware, 3 builds — the minimal one, one with PWM, one with PWM and autolink | 93.99 KB | https://bjlx.org.cn/system/files/procv1_20200523.zip |
| `telnetrc.` | 38 bytes | https://bjlx.org.cn/system/files/telnetrc. |

**[Note]** The zip contains `prcv1.hex`, `prcv1_pwm.hex` and
`prcv1_pwm_autolink.hex`, all reporting `PROC-V1-20200523-d58845a`. That commit
is not in the public [`prc`](https://github.com/osuosl/prc) repository. All three are near-full
flash images; `prcv1_pwm_autolink.hex` reaches 31406 bytes, which **exceeds the
30720 bytes left by the 2 KB bootloader current builds assume** — check a
board's fuses before flashing that image onto it. See
[../AGENTS.md](../AGENTS.md) §3.

**[Note]** `telnetrc.` is exactly the three lines given above.

## Original page navigation (not part of the article)

The site chrome links to: Debian (http://debian.org), flygoat's blog
(https://blog.flygoat.com/), USTC Linux User Association
(https://lug.ustc.edu.cn/wiki/), Loongson official site (http://www.loongson.cn/),
Loongson User Club (http://www.loongsonclub.cn), and the author's blog at
https://bjlx.org.cn/blog/1.

© 2007-2024 北京龙芯用户俱乐部 (Beijing Loongson User Club)
