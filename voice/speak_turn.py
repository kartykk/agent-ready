#!/usr/bin/env python3
"""Stop-hook: speak the last assistant reply (Edge TTS). Not the 'your turn' clip."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NOTIFY = ROOT / "voice" / "notify.py"
MAX_CHARS = 420


def _plain(text: str) -> str:
    text = text or ""
    text = re.sub(r"```[\s\S]*?```", " ", text)
    text = re.sub(r"`[^`]+`", " ", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"[#*_>]{1,3}", " ", text)
    text = re.sub(r"https?://\S+", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def _clip(text: str) -> str:
    text = _plain(text)
    if not text:
        return ""
    parts = re.split(r"(?<=[.!?])\s+", text)
    out = []
    for p in parts:
        if not p:
            continue
        out.append(p)
        joined = " ".join(out)
        if len(joined) >= 180 or len(out) >= 3:
            text = joined
            break
    else:
        text = " ".join(out) or text
    if len(text) > MAX_CHARS:
        text = text[: MAX_CHARS - 1].rsplit(" ", 1)[0] + "."
    return text


def _from_content(content) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        bits = []
        for part in content:
            if isinstance(part, dict) and part.get("type") in ("text", "output_text"):
                bits.append(part.get("text") or "")
            elif isinstance(part, str):
                bits.append(part)
        return " ".join(bits)
    return ""


def _from_transcript(path: str) -> str:
    p = Path(path).expanduser()
    if not p.is_file():
        return ""
    last = ""
    try:
        with p.open(encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                typ = obj.get("type") or obj.get("role") or ""
                if typ not in ("assistant", "ai"):
                    continue
                msg = obj.get("message") or obj
                last = _from_content(msg.get("content") if isinstance(msg, dict) else None)
    except OSError:
        return ""
    return last


def extract(payload: dict) -> str:
    raw = payload.get("last_assistant_message") or ""
    if isinstance(raw, dict):
        raw = _from_content(raw.get("content") or raw)
    text = _clip(str(raw))
    if text:
        return text
    tp = payload.get("transcript_path") or ""
    return _clip(_from_transcript(tp))


def main() -> int:
    raw = sys.stdin.read() if not sys.stdin.isatty() else ""
    payload = {}
    if raw.strip():
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError:
            payload = {}
    if payload.get("stop_hook_active"):
        return 0
    text = extract(payload)
    import subprocess

    py = sys.executable
    if text:
        subprocess.run([py, str(NOTIFY), "say", text], cwd=str(ROOT), check=False)
    else:
        subprocess.run(
            [py, str(NOTIFY), "your_turn"],
            cwd=str(ROOT),
            check=False,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
