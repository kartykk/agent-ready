#!/usr/bin/env bash
# Symlink .agents/skills into .claude/skills so Claude Code sees them.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
mkdir -p "$ROOT/.claude/skills"
for d in "$ROOT/.agents/skills"/*/; do
  [[ -d "$d" ]] || continue
  base="$(basename "$d")"
  ln -sfn "../../.agents/skills/$base" "$ROOT/.claude/skills/$base"
done
echo "linked .claude/skills → .agents/skills"
