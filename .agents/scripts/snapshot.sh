#!/usr/bin/env bash
# Snapshot current tree. Does not need GitHub. Optional commit.
# Usage: snapshot.sh [label] [--commit]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
label="${1:-wip}"
if [[ "$label" == --commit ]]; then
  label=wip
  shift || true
fi
do_commit=0
for a in "${@:-}"; do
  [[ "$a" == --commit ]] && do_commit=1
done

ts="$(date -u +%Y%m%dT%H%M%SZ)"
safe="$(echo "$label" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-40)"
dir=".agents/snapshots/${ts}-${safe}"
mkdir -p "$dir"

{
  echo "time=$ts"
  echo "label=$label"
  echo "pwd=$ROOT"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "branch=$(git rev-parse --abbrev-ref HEAD)"
    echo "head=$(git rev-parse HEAD)"
  else
    echo "git=none"
  fi
} > "$dir/META.txt"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short > "$dir/status.txt" || true
  git diff > "$dir/diff.patch" || true
  git diff --cached > "$dir/cached.patch" || true
else
  echo "no git" > "$dir/status.txt"
fi

mkdir -p .agents/snapshots
echo "| $ts | $label | ${dir} |" >> .agents/SNAPSHOTS.md

if [[ "$do_commit" -eq 1 ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git status --porcelain | grep -q .; then
    echo "snapshot: working tree dirty — not auto-adding the whole tree. Use agent-commit.sh with paths."
  fi
fi

echo "snapshot $dir"
