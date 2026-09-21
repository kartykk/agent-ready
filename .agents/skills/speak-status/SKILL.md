---
name: speak-status
description: Play a short human-touch sound when work finishes or you need the human. done/ok/perfect/need_help plus optional Edge TTS summary.
---

# speak-status

After a finished task, error, or when you need the human:

```bash
bash .agents/scripts/say.sh done "one sentence what you did"
bash .agents/scripts/say.sh perfect
bash .agents/scripts/say.sh ok
bash .agents/scripts/say.sh need_help "blocked on X"
bash .agents/scripts/say.sh error "tests failed"
```

- **Clips** (`done`, `ok`, `perfect`, `need_help`, `error`, `start`): reused files in `voice/clips/`. Bake with Kokoro `am_echo` if installed: `python3 voice/notify.py bake --engine kokoro`.
- **Summary text**: Edge TTS (free). Unique sentences only. Keep to one short line.

Do not speak secrets. Do not fail the task if audio is missing.
