---
name: review-diff
description: Read git diff of your own change before commit. Catch secrets, extra files, leftover debug.
---

# review-diff

Run `git diff` (and `git diff --cached` if staged). Look for:

- `.env`, keys, tokens, passwords
- files you did not mean to touch
- `console.log` / leftover debug
- commented-out piles
- scope creep

Fix those **before** `done-commit`. If the diff is huge, split it.
