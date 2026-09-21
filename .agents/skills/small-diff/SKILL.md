---
name: small-diff
description: Surgical edits only. No drive-by refactors, no rewrite of a whole file for a one-line fix.
---

# small-diff

- Change the smallest set of lines that does the job.
- Do not reformat the rest of the file.
- Do not rename symbols you were not asked to rename.
- Do not add a new framework, folder, or pattern if one already exists.
- If the diff would exceed ~200 lines, stop and split the work.
