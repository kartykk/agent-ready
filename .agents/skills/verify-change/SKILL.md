---
name: verify-change
description: Before claiming done. Run check.sh, show git diff names, run the project’s test/lint if known.
---

# verify-change

1. `git diff --name-only` — only in-scope files?
2. `.agents/scripts/check.sh` if this overlay exists.
3. Run the test/lint command from `AGENTS.md` (or the nearest nested one). If you did not run it, say **not run**.
4. Do not say “done” if checks failed.

Proof in the reply: commands + exit codes, not “should be fine”.
