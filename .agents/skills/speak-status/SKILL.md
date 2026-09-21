---
name: speak-status
description: Play a short reused clip for agent events, then optional Edge TTS summary. Use after finish, block, ask, git, or checks.
---

# speak-status

```bash
bash .agents/scripts/say.sh <clip> "optional unique sentence"
python3 voice/notify.py list
```

**Clip + Edge:** clip is reused wav; extra words are Edge TTS (once).

## Clips

Presence: `ready` `start` `resume` `thinking` `wait`  
Progress: `ok` `progress` `update` `halfway` `almost`  
Success: `done` `perfect` `shipped` `committed` `passed` `all_clear` `installed` `check_ok`  
Human: `hey` `question` `confirm` `review` `your_turn` `handoff` `thanks` `bye`  
Problems: `need_help` `blocked` `warning` `error` `failed` `conflict` `timeout` `refused` `secret` `check_fail`  
Work: `snapshot` `new_task` `claimed`

## When

| Event | Clip |
|-------|------|
| Session open | `ready` or `start` |
| Still working | `wait` / `thinking` / `progress` |
| Need a decision | `question` or `confirm` |
| Task finished | `done` + one-line Edge summary |
| Git commit | `committed` |
| Tests / check.sh | `passed` / `check_ok` or `failed` / `check_fail` |
| Frozen path / refuse | `refused` |
| Stuck | `blocked` or `need_help` |
| Pass to another AI | `handoff` |
| Human should look | `review` / `your_turn` |

Do not speak secrets. Do not fail the task if audio is missing.  
Bake Kokoro Echo: `python3 voice/notify.py bake --engine kokoro`
