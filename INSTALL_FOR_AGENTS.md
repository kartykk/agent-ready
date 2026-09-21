# INSTALL_FOR_AGENTS

You are installing **agent-ready** into `--target` (default: current directory).

## Do

1. `bash /Users/k/Projects/agent-ready/install.sh <target> --name "<project>"`
2. If `GOAL.md` or `STATUS.md` already exist, **do not** overwrite them.
3. Fill remaining `TODO` in GOAL / STATUS / NAMES / ARCHITECTURE from the tree. Ask the human if the product goal is unclear.
4. `bash .agents/scripts/ensure-git.sh` (local git, no GitHub).
5. `bash .agents/scripts/check.sh`
6. Stop. Tell the human the overlay is in. Next: they edit GOAL/STATUS if still TODO.

## Do not

- Do not copy some other product’s `apps/` or firmware.
- Do not install marketplace skills.
- Do not `git push` to GitHub.
- Do not overwrite the target’s source code.
