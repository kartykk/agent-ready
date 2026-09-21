---
name: scope-lock
description: Touch only paths in the current work item. Refuse archive/, LEGACY, and drive-by cleanup.
---

# scope-lock

Allowed: paths named in the BOARD item, the user message, or `spec.md`.

Forbidden unless the human named them:

- `archive/`
- paths in `LEGACY.md`
- unrelated apps, “while I’m here” refactors
- `AGENTS.md` / `.agents/` in the same change as product code

If you need a file outside scope, **ask**. Do not expand scope yourself.
