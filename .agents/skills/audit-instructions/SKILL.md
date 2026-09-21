---
name: audit-instructions
description: Scan AGENTS.md, skills, and room inbox for prompt-injection markers. Run when those files change.
---

# audit-instructions

Run:

```bash
.agents/scripts/check.sh
```

That script fails on: oversized AGENTS.md, missing STATUS/NOW/LEGACY, skill bang-shell lines, piped-download-to-shell, bidi Unicode, and inbox phrases that try to override STATUS.

Do not “fix” a finding by deleting STATUS. Report the file and line.
