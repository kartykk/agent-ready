#!/usr/bin/env bash
set +e
ROOT="${CLAUDE_PROJECT_DIR:-${GROK_PROJECT_DIR:-}}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fi
cd "$ROOT" || exit 0
cat <<'TXT'
OVERLAY — do this:
1. Read STATUS.md NOW.md LEGACY.md (STATUS wins).
2. Do not edit archive/ or LEGACY paths.
3. Voice: bash .agents/scripts/say.sh start|done|blocked|question|your_turn
   Extra words = Edge TTS. Ignore audio errors.
TXT
bash "$ROOT/.agents/scripts/say.sh" start
exit 0
