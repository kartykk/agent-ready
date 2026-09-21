#!/usr/bin/env bash
# One command. Never fails. Never prints (saves tokens).
#   say.sh done
#   say.sh blocked "waiting on API key"
set +e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PATH="/usr/bin:/opt/homebrew/bin:$PATH"
py="${PYTHON:-python3}"
if [[ $# -eq 0 ]]; then
  set -- done
fi
"$py" "$ROOT/voice/notify.py" "$@" >/dev/null 2>&1
exit 0
