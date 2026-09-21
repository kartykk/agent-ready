---
name: apply-overlay
description: Install agent-ready into another folder. Use when the human wants this kit on a new or existing project.
---

# apply-overlay

1. Read `INSTALL_FOR_AGENTS.md` in the **agent-ready** repo (`/Users/k/Projects/agent-ready`).
2. Run:

```bash
bash /Users/k/Projects/agent-ready/install.sh <target> --name "<Project>"
cd <target>
bash .agents/scripts/ensure-git.sh
bash .agents/scripts/check.sh
```

3. Do not overwrite existing GOAL.md / STATUS.md.
4. Fill TODOs from the target tree or ask.
5. Stop.
