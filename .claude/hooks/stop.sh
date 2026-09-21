#!/usr/bin/env bash
# Speak the last reply (Edge TTS). Never block stop.
set +e
ROOT="${CLAUDE_PROJECT_DIR:-${GROK_PROJECT_DIR:-}}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fi
export PATH="/usr/bin:/opt/homebrew/bin:$PATH"
py="${PYTHON:-python3}"
"$py" "$ROOT/voice/speak_turn.py"
exit 0
