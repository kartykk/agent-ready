#!/usr/bin/env bash
# End of Claude/Grok turn → human's turn sound. Never block the stop.
set +e
ROOT="${CLAUDE_PROJECT_DIR:-${GROK_PROJECT_DIR:-}}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fi
bash "$ROOT/.agents/scripts/say.sh" your_turn
exit 0
