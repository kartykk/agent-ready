#!/usr/bin/env bash
# One worktree per agent so two AIs do not edit the same files.
# Usage: worktree-agent.sh grok W-003
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
agent="${1:?agent name: grok|claude|cursor|gemini}"
work="${2:-work}"
safe="$(echo "$work" | tr -c 'A-Za-z0-9._-' '-' | cut -c1-32)"
branch="agent/${agent}/${safe}"
dest="$ROOT/.agents/worktrees/${agent}-${safe}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "run ensure-git.sh first" >&2
  exit 1
fi

mkdir -p "$ROOT/.agents/worktrees"
if [[ -d "$dest" ]]; then
  echo "exists $dest (branch $branch)"
  echo "$dest"
  exit 0
fi
git worktree add -b "$branch" "$dest"
echo "worktree $dest on $branch"
echo "$dest"
