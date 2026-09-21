---
name: git-safety
description: Git rules for any project. No GitHub push unless the human said so. No force, no .env.
---

# git-safety

- If there is no `.git`, run `.agents/scripts/ensure-git.sh` (local only).
- Commit with `.agents/scripts/agent-commit.sh '<msg>' <paths>` — **pass paths**. Never `git add -A` on the whole tree.
- `git push local` (offline backup) is OK.
- **Do not** `git push` to GitHub/origin unless the human said “push”.
- **Do not** `--force` on main/master.
- **Do not** commit `.env` or private keys.
- **Do not** `git reset --hard` unless the human asked to throw work away.
