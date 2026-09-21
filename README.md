# agent-ready

Drop-in overlay so **any** coding agent (Grok, Claude, Cursor, Codex, Gemini, Qwen) can work a repo without inventing a second map.

Not tied to Kinokora. No GitHub required.

## Tell an AI

> Install from `/Users/k/Projects/agent-ready`. Follow `INSTALL_FOR_AGENTS.md`. Do not overwrite GOAL.md or STATUS.md if they exist. Then read AGENTS.md.

## New empty project

```bash
mkdir ~/Projects/my-app && cd ~/Projects/my-app
bash /Users/k/Projects/agent-ready/install.sh . --name "My App"
# edit GOAL.md STATUS.md NAMES.md
bash .agents/scripts/ensure-git.sh
```

## Existing project

```bash
cd /path/to/existing
bash /Users/k/Projects/agent-ready/install.sh . --name "My App"
# existing GOAL.md / STATUS.md are kept
```

## What lives here

| File | Question |
|------|----------|
| `GOAL.md` | Why the product exists |
| `ARCHITECTURE.md` | How pieces connect |
| `AGENTS.md` | Rules every AI must follow |
| `STATUS.md` | Live paths |
| `NOW.md` | What is in flight |
| `.agents/skills/CATALOG.md` | 17 short skills (weaker models pick one) |
| `.agents/scripts/ensure-git.sh` | `git init` + **local** backup, no GitHub |
| `.agents/scripts/agent-commit.sh` | Commit + snapshot; never GitHub-push |
| `.agents/CONTINUE.md` | Relay to the next AI |

Thin adapters (`CLAUDE.md`, `GEMINI.md`, `QWEN.md`, `.cursorrules`) only point at `AGENTS.md`.

## Compared to other OSS

| Kit | We took | We skipped |
|-----|---------|------------|
| [agent-handoff-kit](https://github.com/jimozo/agent-handoff-kit) | `INSTALL_FOR_AGENTS.md`, install into target, CONTINUE/SESSIONS | Vendoring their whole kit |
| [github-template-ai-agents](https://github.com/d-o-hub/github-template-ai-agents) | One AGENTS.md, thin tool files, skills in `.agents/skills` | 900-file CI / Sonar / GOAP |
| Spec Kit / GSD / Beads | Atomic commit + snapshots | npm/uv runtimes |

## License

Use it. Fill GOAL/STATUS for *your* product.
