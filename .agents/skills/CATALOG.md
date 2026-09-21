# Skill catalog (any project)

First-party only. Do **not** install marketplace skills.

Weaker models: pick **one** skill from “When” and read that `SKILL.md` before acting.

## Session (always)

| When | Skill |
|------|--------|
| Install this kit into another folder | `apply-overlay` |
| New chat / “where were we” | `start-session` |
| Starting a BOARD item | `take-work` |
| Task finished | `done-commit` |
| Pass to another AI | `handoff` |
| Instruction files changed | `audit-instructions` |

## Before code

| When | Skill |
|------|--------|
| Request is vague or large | `plan-first` |
| About to edit a file | `read-before-edit` |
| Not sure / two options | `ask-when-blocked` |

## While coding

| When | Skill |
|------|--------|
| Writing or changing code | `small-diff` |
| Bug / “it doesn’t work” | `debug-with-evidence` |
| Copy a pattern from the repo | `match-existing` |
| Tempted to “also clean up” | `scope-lock` |

## Before you say done

| When | Skill |
|------|--------|
| About to commit or claim done | `verify-change` |
| Look at your own patch | `review-diff` |
| Git / push / .env | `git-safety` |
| Tokens, keys, passwords | `no-secrets` |
| Finished the one task | `stop-when-done` |
| Play done / need-help sound | `speak-status` |
