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

**⚠ We do not squash-merge.** Every commit you write lands on `main` intact,
which means **every commit** is parsed by release-please and shows up in the
changelog on its own. Write them accordingly: one logical change each, with a
subject that reads well in a release note.

CI checks every commit in a PR for both a conventional subject and a
`Signed-off-by` trailer. A non-conventional subject doesn't fail at release
time — the change just silently never appears in the changelog.

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

## Merging

**Merge commit or rebase — never squash.** Squashing collapses a branch into one
commit, which would reduce a PR's worth of distinct fixes to a single changelog
line and lose the individual sign-offs. Squash merging is disabled on the
repository for that reason.

Keep the branch tidy before it merges, since nothing will tidy it afterwards:
fold up "fix typo" commits with `git rebase -i`, and make sure each surviving
commit is one logical change.

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

## Dependency updates

Dependabot opens a **single grouped PR** for GitHub Actions, weekly on Monday.
One PR for all actions rather than one per action; if a major bump breaks
something, CI says so on that PR.

Its commits are prefixed **`chore(deps):`**, which does three things:

- **No release.** Only `feat`, `fix` and breaking changes bump a version, so
  merging a Dependabot PR never mints a new firmware version on its own.
- **No changelog noise.** `chore` is hidden, so action bumps stay out of release
  notes read by someone deciding whether to reflash a board.
- **It passes CI.** Without a conventional prefix every Dependabot PR would fail
  the commit check.

Bot authors are exempt from the sign-off requirement, because Dependabot has no
DCO option. They are *not* exempt from the format check — if that prefix is ever
removed from `.github/dependabot.yml`, CI will catch it.

**⚠ The Arduino pins are not covered.** There is no Dependabot ecosystem for
`arduino-cli`, so these, in `.github/workflows/*.yml`, have to be reviewed by
hand:

| Pin | Current |
|---|---|
| `PLATFORM_VERSION` (`arduino:avr`) | 1.8.8 |
| `ONEWIRE_VERSION` | 2.3.8 |
| `ETHERNET3_VERSION` | 1.6.0 |

That is deliberate. This firmware sits at ~95% of a 30720 byte flash, so a core
or library bump can push it over the ceiling, change generated code, or alter
timing. Bump one at a time, on its own PR, and read the size delta CI posts.

## What CI enforces

| Check | Blocking | Notes |
|---|---|---|
| Builds for `stock` and `-DPWM=5` | yes | both variants must compile |
| Flash headroom ≥ 512 bytes free | yes | avr-gcc enforces the hard 30720 ceiling itself |
| Size delta report | no | posted on the PR; watch it, headroom is ~1.6 KB |
| Compiler warnings | no | reported only — there are ~28 already; don't add more |
| `astyle` formatting | yes | run `tools/format.sh` before pushing |
| Conventional subject + sign-off, every commit | yes | commits land on `main` intact and drive the changelog |
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
