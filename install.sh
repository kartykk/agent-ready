#!/usr/bin/env bash
# Copy this overlay into another folder. GitHub not required.
# Usage: install.sh <target-dir> [--name "My App"] [--force]
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
target=""
name=""
force=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) name="${2:-}"; shift 2 ;;
    --force) force=1; shift ;;
    --) shift; break ;;
    -*) echo "unknown flag $1" >&2; exit 2 ;;
    *) target="$1"; shift ;;
  esac
done
[[ -n "$target" ]] || { echo "usage: install.sh <dir> [--name NAME] [--force]" >&2; exit 2; }
mkdir -p "$target"
target="$(cd "$target" && pwd)"

copy_if() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && "$force" -ne 1 ]]; then
    echo "keep $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  echo "write $dest"
}

# Always refresh mechanics
mkdir -p "$target/.agents" "$target/.github"
rm -rf "$target/.agents/skills" "$target/.agents/scripts"
cp -R "$KIT/.agents/skills" "$target/.agents/skills"
cp -R "$KIT/.agents/scripts" "$target/.agents/scripts"
chmod +x "$target/.agents/scripts"/*.sh

for f in PROTOCOL.md TRUSTED.md SESSIONS.md SESSIONS_ARCHIVE.md CONTINUE.md SNAPSHOTS.md; do
  copy_if "$KIT/.agents/$f" "$target/.agents/$f"
done
mkdir -p "$target/.agents/work" "$target/.agents/room/inbox"
copy_if "$KIT/.agents/work/BOARD.md" "$target/.agents/work/BOARD.md"
copy_if "$KIT/.agents/work/README.md" "$target/.agents/work/README.md"
touch "$target/.agents/room/inbox/.gitkeep"

# Product maps from stubs (not this kit’s own GOAL)
for f in GOAL.md ARCHITECTURE.md STATUS.md NOW.md LEGACY.md NAMES.md; do
  copy_if "$KIT/project-stubs/$f" "$target/$f"
done
# Rules + adapters from the kit
for f in AGENTS.md CLAUDE.md GEMINI.md QWEN.md .cursorrules .gitignore; do
  copy_if "$KIT/$f" "$target/$f"
done
copy_if "$KIT/.github/copilot-instructions.md" "$target/.github/copilot-instructions.md"
# Voice: clips + notify (always refresh notify.py; keep dest clips if present)
mkdir -p "$target/voice/clips"
cp "$KIT/voice/notify.py" "$target/voice/notify.py"
copy_if "$KIT/voice/README.md" "$target/voice/README.md"
copy_if "$KIT/requirements-voice.txt" "$target/requirements-voice.txt"
if [[ -d "$KIT/voice/clips" ]]; then
  for w in "$KIT/voice/clips"/*.wav; do
    [[ -f "$w" ]] || continue
    base="$(basename "$w")"
    copy_if "$w" "$target/voice/clips/$base"
  done
fi
# say.sh lives in scripts (already copied)

if [[ -n "$name" ]]; then
  if grep -q 'TODO product name' "$target/NAMES.md" 2>/dev/null; then
    printf '# Names\n\n| Name | Meaning |\n|------|---------|\n| **%s** | The thing you ship |\n' "$name" > "$target/NAMES.md"
    echo "stamped NAMES.md as $name"
  fi
  if grep -q '\*\*TODO:\*\* one paragraph' "$target/GOAL.md" 2>/dev/null; then
    printf '# Goal\n\n**%s** — TODO: one paragraph, who it is for, what done means.\n\n## Must stay true\n\n- TODO: invariants\n' "$name" > "$target/GOAL.md"
    echo "stamped GOAL.md title"
  fi
fi

# Claude Code hooks (sound + overlay reminder even if the model ignores AGENTS.md)
mkdir -p "$target/.claude/hooks"
cp "$KIT/.claude/hooks/"*.sh "$target/.claude/hooks/" 2>/dev/null || true
chmod +x "$target/.claude/hooks/"*.sh 2>/dev/null || true
copy_if "$KIT/.claude/settings.json" "$target/.claude/settings.json"

# Thin Claude skill links (best-effort)
if command -v ln >/dev/null; then
  mkdir -p "$target/.claude/skills"
  for d in "$target/.agents/skills"/*/; do
    [[ -d "$d" ]] || continue
    base="$(basename "$d")"
    [[ "$base" == .* ]] && continue
    ln -sfn "../../.agents/skills/$base" "$target/.claude/skills/$base"
  done
fi

echo "installed overlay → $target"
echo "next: cd $target && bash .agents/scripts/ensure-git.sh && bash .agents/scripts/check.sh"
echo "then fill GOAL.md STATUS.md if they still say TODO"
