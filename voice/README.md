# Voice (human touch)

| Kind | Engine |
|------|--------|
| Reused clips (~35) | Kokoro `am_echo` if installed, else Edge GuyNeural, cached wav |
| Extra sentence | Edge TTS (free) |

```bash
python3 voice/notify.py list
python3 voice/notify.py bake
bash .agents/scripts/say.sh done "Committed thirty five clips"
bash .agents/scripts/say.sh question "Ship kpack or wait"
```

See `.agents/skills/speak-status/SKILL.md` for when to use which clip.
