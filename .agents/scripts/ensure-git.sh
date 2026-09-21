#!/usr/bin/env bash
# Create a local git repo even if GitHub does not exist. Never talks to github.com.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if ! command -v git >/dev/null; then
  echo "git is not installed" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -b main
  git config user.email >/dev/null 2>&1 || git config user.email "agent@local"
  git config user.name >/dev/null 2>&1 || git config user.name "agent"
  git add -A -- AGENTS.md GOAL.md ARCHITECTURE.md STATUS.md NOW.md LEGACY.md NAMES.md .agents 2>/dev/null || true
  if git status --porcelain | grep -q .; then
    git add -A -- AGENTS.md GOAL.md ARCHITECTURE.md STATUS.md NOW.md LEGACY.md NAMES.md CLAUDE.md .agents || true
    git commit -m "chore: local git init (no GitHub)"
  fi
  echo "git init OK (local)"
else
  echo "git already present: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
fi

# Local bare backup — works offline, no GitHub account
BARE="$ROOT/.agents/local-git/backup.git"
mkdir -p "$(dirname "$BARE")"
if [[ ! -d "$BARE" ]]; then
  git init --bare "$BARE"
fi
if ! git remote get-url local >/dev/null 2>&1; then
  git remote add local "$BARE"
fi
# Push current HEAD to local backup (not GitHub)
git push -u local HEAD >/dev/null 2>&1 || git push local HEAD >/dev/null 2>&1 || true
echo "local backup remote: $BARE"
echo "ensure-git OK"
