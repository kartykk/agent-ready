---
name: done-commit
description: Finish a BOARD row. Update NOW and create a local git commit. Never push.
---

# done-commit

1. Check remaining boxes in the work `tasks.md`.
2. Set BOARD status to `done` (or leave `doing` if more remains — then stop).
3. Update `NOW.md` Last done / Next.
4. Run:

```bash
.agents/scripts/agent-commit.sh "chore(agents): W-NNN short title" <paths>
```

That script also writes a snapshot, `git push local` if the offline remote exists, and plays **committed**. It still does **not** push to GitHub.

5. If the script errors, fix staging — do not add unrelated dirty files.
6. **Do not** `git push`. Human says push.

The script refuses `push` and refuses committing `.env`.
