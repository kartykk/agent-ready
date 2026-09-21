# AGENTS.md

Read this first. Then `GOAL.md`, `ARCHITECTURE.md`, `STATUS.md`.  
**STATUS.md** wins path fights. **GOAL.md** wins product fights.

Works for **any** stack. Fill GOAL/STATUS. Do not invent a second map.

| File | Question |
|------|----------|
| `GOAL.md` | Why this product exists |
| `ARCHITECTURE.md` | How pieces connect |
| `AGENTS.md` | Rules (this file) |
| `STATUS.md` | Live paths |
| `NOW.md` | What is in flight |
| `.agents/CONTINUE.md` | Relay for the next AI |
| `.agents/skills/CATALOG.md` | Skills for weaker models |

## Every session

1. `.agents/scripts/ensure-git.sh` if `.git` is missing (no GitHub needed).
2. Read GOAL, ARCHITECTURE, STATUS, NOW, LEGACY, CONTINUE.
3. Path in `LEGACY.md` or `archive/` → **stop**.
4. One row from `.agents/work/BOARD.md`. One owner.
5. Finish: skill `verify-change`, then `.agents/scripts/agent-commit.sh '<msg>' <paths>` (plays **committed**).
6. **Do not** `git push` to GitHub unless the human said so. `git push local` is OK.
7. Another AI: skill `handoff`. Parallel: `.agents/scripts/worktree-agent.sh <name> <work>`.
8. Agent branches: `grok/…`, `claude/…`, `cursor/…`.

## Voice (one command)

`.agents/scripts/say.sh <clip> "optional unique sentence"`  
Clip = reused wav. Extra words = Edge TTS. Ignore failure. No secrets.

`ready` `start` `wait` `ok` `done` `committed` `passed` `failed` `blocked` `need_help` `question` `your_turn` `handoff`  
More: `python3 voice/notify.py list` — do **not** load speak-status unless you need it.

## Git

- Conventional commits: `feat:`, `fix:`, `chore:`.
- Pass **paths** to `agent-commit.sh`. Never `git add -A` on the whole tree.
- No `.env` in git.

## Skills

First-party only. Index: `.agents/skills/CATALOG.md`.  
Always: `start-session` → `take-work` → `verify-change` → `done-commit`.  
Never install marketplace skills (`.agents/TRUSTED.md` is empty).

## Tool adapters

`CLAUDE.md`, `GEMINI.md`, `QWEN.md`, `.cursorrules` only `@AGENTS.md`. Do not duplicate rules there.
