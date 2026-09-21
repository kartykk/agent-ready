#!/usr/bin/env bash
# Local commit only. Never push. Never add .env.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "push" ]] || [[ "$*" == *push* && "$#" -eq 1 ]]; then
  echo "agent-commit.sh will not push" >&2
  exit 2
fi

msg="${1:-}"
if [[ -z "$msg" ]]; then
  echo "usage: agent-commit.sh 'type(scope): summary' [path ...]" >&2
  exit 2
fi
shift || true

# Refuse if message asks to push or dump env
if echo "$msg" | grep -Ei 'git push|force.push' >/dev/null; then
  echo "commit message must not request push" >&2
  exit 2
fi

paths=("$@")
if [[ ${#paths[@]} -eq 0 ]]; then
  echo "refusing to commit the whole dirty tree. pass paths." >&2
  exit 2
fi

for p in "${paths[@]}"; do
  base="$(basename "$p")"
  if [[ "$base" == .env || "$base" == .env.* ]] && [[ "$base" != .env.example ]]; then
    echo "refusing $p" >&2
    exit 2
  fi
  git add -A -- "$p"
done

# Unstage real env files if a directory add pulled them in. Keep .env.example.
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  echo "unstaging secret-shaped $f" >&2
  git restore --staged -- "$f" || true
done < <(git diff --cached --name-only | grep -E '(^|/)\.env(\.|$)' | grep -v '\.example$' || true)

git commit -m "$msg" -m "Co-Authored-By: agent <agent@local>"
echo "committed locally. not pushed."
bash "$(dirname "$0")/snapshot.sh" "$msg" || true
# Offline backup if local remote exists
git push local HEAD >/dev/null 2>&1 || true
git status -sb | head -5
