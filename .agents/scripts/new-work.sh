#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
slug="${1:-}"
title="${2:-$slug}"
if [[ -z "$slug" ]]; then
  echo "usage: new-work.sh slug 'Title'" >&2
  exit 2
fi
last=$(grep -E '^\| W-[0-9]+' .agents/work/BOARD.md | tail -1 | sed -E 's/^\| W-0*([0-9]+).*/\1/' || true)
n=$(( ${last:-0} + 1 ))
id=$(printf "W-%03d" "$n")
dir=".agents/work/${id}-${slug}"
mkdir -p "$dir"
printf '# %s — %s\n\n' "$id" "$title" > "$dir/spec.md"
printf '# Plan\n\n- [ ] …\n' > "$dir/plan.md"
printf '# Tasks\n\n- [ ] …\n' > "$dir/tasks.md"
printf '# Notes\n' > "$dir/notes.md"
echo "| $id | $title | — | open |" >> .agents/work/BOARD.md
echo "created $dir"
