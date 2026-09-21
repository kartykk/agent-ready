#!/usr/bin/env bash
# Play a reused clip (Kokoro Echo / Edge) then optional Edge TTS summary.
# Usage: say.sh done "Committed W-004"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PATH="/usr/bin:/opt/homebrew/bin:$PATH"
py="${PYTHON:-python3}"
exec "$py" "$ROOT/voice/notify.py" "$@"
