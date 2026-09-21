# Goal

**agent-ready** is a drop-in overlay so any coding agent can work any repo: one map, local git without GitHub, snapshots, multi-AI handoff, short skills.

## Must stay true

- Stack-agnostic. No Kinokora / crop / firmware rules in this kit.
- `AGENTS.md` is the only shared rule file. Tool files stay thin.
- First-party skills only. No marketplace installs.
- GitHub is optional. `ensure-git.sh` + `git push local` must work offline.
- Install must not overwrite an existing `GOAL.md` / `STATUS.md` unless `--force`.
