#!/usr/bin/env bash
# Overlay health + instruction-file scan. Never pushes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
fail=0
say() { echo "$*"; }
bad() { echo "FAIL: $*" >&2; fail=1; }

need=(AGENTS.md GOAL.md ARCHITECTURE.md STATUS.md NOW.md LEGACY.md NAMES.md CLAUDE.md .agents/PROTOCOL.md .agents/work/BOARD.md .agents/SESSIONS.md .agents/CONTINUE.md voice/notify.py)
for f in "${need[@]}"; do
  [[ -f "$f" ]] || bad "missing $f"
done

if [[ -f AGENTS.md ]]; then
  lines=$(wc -l < AGENTS.md | tr -d ' ')
  if [[ "$lines" -gt 200 ]]; then
    bad "AGENTS.md is $lines lines (max 200)"
  else
    say "AGENTS.md lines=$lines"
  fi
  grep -q 'STATUS.md' AGENTS.md || bad "AGENTS.md must name STATUS.md"
fi

if [[ -f CLAUDE.md ]]; then
  grep -q 'AGENTS.md' CLAUDE.md || bad "CLAUDE.md must mention AGENTS.md"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  say "git=$(git rev-parse --abbrev-ref HEAD)"
else
  bad "no git — run .agents/scripts/ensure-git.sh (GitHub not required)"
fi

# Bidi / dangerous unicode in instruction surfaces
while IFS= read -r f; do
  if grep -q $'\u202e\|\u200b\|\u2066\|\u2067\|\u2068' "$f" 2>/dev/null; then
    bad "hidden unicode in $f"
  fi
done < <(find AGENTS.md CLAUDE.md GEMINI.md .agents -type f -name '*.md' ! -name '*.example.md' 2>/dev/null)

# Skill dynamic-context: a line that is only "! command"
while IFS= read -r f; do
  if grep -E '^[[:space:]]*!' "$f" >/dev/null 2>&1; then
    bad "skill shell interpolation (!) in $f"
  fi
done < <(find .agents/skills -name SKILL.md 2>/dev/null)

# curl|bash in overlay (except this scanner naming it)
while IFS= read -r f; do
  if grep -EIq 'curl.{0,80}\|(ba)?sh' "$f"; then
    bad "piped-download-to-shell in $f"
  fi
done < <(find AGENTS.md CLAUDE.md .agents -type f -name '*.md' ! -name '*.example.md' 2>/dev/null)

# Inbox: override attempts (untrusted)
shopt -s nullglob
for f in .agents/room/inbox/*.md; do
  [[ "$(basename "$f")" == *.example.md ]] && continue
  if grep -EIq 'ignore previous|you are now|git push|cat .*\.env' "$f"; then
    bad "inbox override/exfil pattern in $f"
  fi
done

# Instruction files must not contain PEM/keys
for f in AGENTS.md CLAUDE.md NOW.md; do
  if grep -E 'BEGIN (RSA |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}' "$f" >/dev/null 2>&1; then
    bad "secret-shaped material in $f"
  fi
done

if [[ "$fail" -ne 0 ]]; then
  echo "check.sh failed" >&2
  exit 1
fi
echo "check.sh OK"
exit 0
