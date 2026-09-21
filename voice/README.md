# Voice (human touch)

| Kind | Engine | When |
|------|--------|------|
| `done` `ok` `perfect` `need_help` `error` `start` `wait` | **Kokoro `am_echo`** (male) if installed, else Edge male, cached as wav | Same phrase every time |
| extra sentence | **Edge TTS** (free, online) | Unique summary |

```bash
python3 voice/notify.py bake --engine kokoro   # once, if kokoro installed
python3 voice/notify.py bake                   # Edge fallback
bash .agents/scripts/say.sh done "Committed overlay"
```

Copied from DocuVoice (`app/tts_engine.py`): Edge stream + Kokoro pipeline. No karaoke/timings.

`pip install edge-tts` (required for summaries). Optional: `pip install kokoro soundfile numpy`.
