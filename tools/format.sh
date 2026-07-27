#!/bin/bash
# Reformat the sketch the way upstream does, so our diffs stay rebase-friendly.
# The config is vendored from lshw/procV2 (lib/formatter.conf), which is where
# upstream keeps it -- that repo is not forked, so it lives here instead.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v astyle >/dev/null; then
  echo "astyle not found: apt install astyle" >&2
  exit 1
fi
astyle --options=tools/formatter.conf --suffix=none prc/prc.ino
git diff --stat -- prc/prc.ino
