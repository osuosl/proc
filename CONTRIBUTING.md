# Contributing

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/), because
[release-please](https://github.com/googleapis/release-please) derives the
version bump and the changelog from them.

```
fix: reclaim auth slots when a peer disconnects

Longer explanation of why, what breaks without it, and what you tested.

Refs: #14
Signed-off-by: Your Name <you@example.org>
```

| Type | Use for | Bumps |
|---|---|---|
| `feat` | new capability | minor |
| `fix` | a defect | patch |
| `perf` | flash or RAM savings, speedups | patch |
| `docs`, `build`, `ci`, `refactor`, `test`, `chore` | everything else | none |

Breaking changes get a `!` (`feat!: ...`) or a `BREAKING CHANGE:` footer. For
this firmware "breaking" means something an operator would be caught out by —
an EEPROM layout change that discards settings, a changed default, a renamed
menu key, or a MAC address change.

**⚠ PRs are squash-merged, so the PR *title* becomes the commit on `main`.**
That title is what release-please parses, so it has to be conventional too. CI
checks it. An unconventional title doesn't fail loudly at release time — the
change just silently vanishes from the changelog.

## Sign off every commit

```bash
git commit -s
```

Every commit needs a `Signed-off-by:` trailer (the
[DCO](https://developercertificate.org/)). PRs without it will be asked to
amend. `-s` generates it from your git identity; don't write the line by hand.

## Releases

Merging to `main` makes release-please open (or update) a release PR that bumps
`version.txt` and `CHANGELOG.md`. **Merging that PR is the release**: it tags
`vX.Y.Z`, publishes the GitHub Release, and triggers the build that attaches
`.hex`, `.elf`, `SHA256SUMS` and `toolchain.txt`.

To force a specific version, put `Release-As: 1.0.0` in a commit footer.

The version is compiled into the image and shown in the telnet banner as
`#Ver:PROC-V1-X.Y.Z-g<sha>`, so a banner read off a deployed board always maps to
an exact commit. Never hand-edit [CHANGELOG.md](CHANGELOG.md) or `version.txt`;
release-please owns both.

Two things to know:

- Release PRs are created with `GITHUB_TOKEN`, so **CI does not run on them.**
  That is a GitHub restriction, not a misconfiguration. The content is generated
  from commits that already passed CI on `main`.
- **Nothing is hardware-tested by CI.** A green release means it compiles and
  fits. Flash a spare board before rolling a release out to a fleet.

## ⚠ Check the base repo on every PR

This repository is a **fork**, so GitHub defaults the base of a new pull request
to **`lshw/proc`** — upstream — not to us. Opening a PR without checking means
proposing your change to the original author instead of to OSL.

Always confirm the base is `osuosl/proc` and the branch is `main`:

```bash
gh pr create --repo osuosl/proc --base main
```

There is no repository setting that changes this default; it has to be checked
each time.

## Branch model

- `main` is the maintained line. It is protected and takes changes by PR.
- Work on a topic branch, open a PR, get CI green.
- `upstream/main` tracks [`lshw/proc`](https://github.com/lshw/proc).

## Syncing with upstream: merge, never rebase

```bash
git fetch upstream
git checkout main
git merge upstream/main       # NOT rebase
```

**This matters.** Our translation commit rewrites every Chinese comment in
`prc/prc.ino`, both README files and `build.sh`. Rebasing `main` onto upstream
replays that commit on top of theirs and re-conflicts *every line, every time*.
Merging conflicts once, only where upstream actually touched the same lines.

Expected conflict points:

| File | Why |
|---|---|
| `prc/prc.ino` | ~64 comment lines translated |
| `build.sh` | messages and comments translated |
| `README.md` | rewritten for the fork |

When resolving, keep our English and fold in upstream's *behaviour* change.

## Sending fixes upstream

The author is responsive and ships these boards commercially, so genuine fixes
are worth sending back. Upstream is Chinese-language; a bilingual subject line
is a courtesy:

```bash
git format-patch -1 --to=liushiwei@gmail.com
# or
gh pr create --repo lshw/proc --base main
```

Send the **behaviour change alone**, without the translation — a patch that also
retranslates his comments is unlikely to be merged, and rightly so.

## What CI enforces

| Check | Blocking | Notes |
|---|---|---|
| Builds for `stock` and `-DPWM=5` | yes | both variants must compile |
| Flash headroom ≥ 512 bytes free | yes | avr-gcc enforces the hard 30720 ceiling itself |
| Size delta report | no | posted on the PR; watch it, headroom is ~1.6 KB |
| Compiler warnings | no | reported only — there are ~28 already; don't add more |
| `astyle` formatting | yes | run `tools/format.sh` before pushing |
| Conventional PR title | yes | it becomes the squash commit release-please reads |
| Relative markdown links resolve | yes | cross-repo links must be absolute URLs |

Before pushing:

```bash
tools/format.sh     # astyle, using upstream's config
./build.sh          # confirm it still fits
```

## Firmware-specific rules

- **Watch the flash number on every build.** ~1.6 KB of headroom. A feature that
  doesn't fit isn't a feature.
- **Don't reformat.** `tools/format.sh` only, and only lines you touched.
  Gratuitous reformatting makes every future upstream merge worse.
- **Don't change the pin defines.** `_24V_OUT`=D3, `NET_RESET`=D4, W5500 SPI on
  D10–D13, `DS`=A3, `PC_RESET`=A4, `PC_POWER`=A5. They are fixed by the PCB; see
  [osuosl/prc](https://github.com/osuosl/prc).
- **Cite `file:line`.** One 1400-line file with no headers.
- **Say what you tested.** "Builds and fits" and "tested on hardware" are very
  different claims. Put whichever is true in the commit message — several
  existing commits say "not yet tested on hardware" for exactly this reason.
