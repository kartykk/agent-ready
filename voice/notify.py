#!/usr/bin/env python3
"""Agent voice: baked clips for repeated alerts, Edge TTS for unique summaries.

Repeated phrases (done / ok / perfect / need_help / error / start):
  Kokoro voice am_echo (male) when kokoro is installed — else Edge male, then macOS say.

One-off summary text:
  Edge TTS (free, online). Fallback: macOS say.

Copied from DocuVoice tts_engine.py (Edge stream + Kokoro pipeline), trimmed.
"""
from __future__ import annotations

import argparse
import asyncio
import hashlib
import io
import os
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CLIPS = ROOT / "clips"
CACHE = ROOT / "cache"
KOKORO_VOICE = os.environ.get("AGENT_KOKORO_VOICE", "am_echo")
EDGE_VOICE = os.environ.get("AGENT_EDGE_VOICE", "en-US-GuyNeural")
EDGE_ENABLED = os.environ.get("EDGE_TTS_ENABLED", "true").strip().lower() not in (
    "0",
    "false",
    "no",
    "off",
)

PHRASES = {
    "done": "Done.",
    "ok": "Okay.",
    "perfect": "Perfect.",
    "need_help": "Need help.",
    "help": "Need help.",
    "error": "Error.",
    "start": "Starting.",
    "wait": "Working.",
}

try:
    import edge_tts

    EDGE_OK = True
except ImportError:
    EDGE_OK = False

try:
    from kokoro import KPipeline

    KOKORO_OK = True
except ImportError:
    KOKORO_OK = False
    KPipeline = None  # type: ignore


def _run_async(coro):
    box = {}

    def _runner():
        try:
            box["result"] = asyncio.run(coro)
        except BaseException as exc:  # noqa: BLE001
            box["error"] = exc

    t = threading.Thread(target=_runner, daemon=True)
    t.start()
    t.join()
    if "error" in box:
        raise box["error"]
    return box.get("result")


async def _edge_mp3(text: str, voice: str, speed: float = 1.0) -> bytes:
    clamped = max(0.5, min(2.0, speed))
    rate = f"{int(round((clamped - 1.0) * 100)):+d}%"
    communicate = edge_tts.Communicate(text, voice, rate=rate)
    audio = bytearray()
    async for chunk in communicate.stream():
        if chunk.get("type") == "audio":
            audio.extend(chunk["data"])
    return bytes(audio)


def _mp3_to_wav(mp3: bytes) -> bytes:
    try:
        import soundfile as sf
        import numpy as np

        data, sr = sf.read(io.BytesIO(mp3), dtype="float32")
        if getattr(data, "ndim", 1) > 1:
            data = data.mean(axis=1)
        buf = io.BytesIO()
        sf.write(buf, np.asarray(data), sr, format="WAV")
        buf.seek(0)
        return buf.read()
    except Exception:
        pass
    # ffmpeg fallback
    with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
        f.write(mp3)
        src = f.name
    dst = src + ".wav"
    try:
        subprocess.run(
            ["ffmpeg", "-y", "-i", src, "-ac", "1", dst],
            check=True,
            capture_output=True,
        )
        return Path(dst).read_bytes()
    finally:
        for p in (src, dst):
            try:
                os.unlink(p)
            except OSError:
                pass


def synth_edge(text: str) -> bytes | None:
    if not (EDGE_OK and EDGE_ENABLED):
        return None
    try:
        mp3 = _run_async(_edge_mp3(text, EDGE_VOICE))
        if not mp3:
            return None
        return _mp3_to_wav(mp3)
    except Exception as e:
        print(f"edge-tts: {e}", file=sys.stderr)
        return None


_pipeline = None


def synth_kokoro(text: str, voice: str = KOKORO_VOICE) -> bytes | None:
    if not KOKORO_OK:
        return None
    global _pipeline
    try:
        import numpy as np
        import soundfile as sf

        if _pipeline is None:
            _pipeline = KPipeline(lang_code=voice[0] if voice else "a")
        gen = _pipeline(text, voice=voice, speed=1.0)
        segs = []
        for item in gen:
            audio = getattr(item, "audio", None)
            if audio is None and isinstance(item, (tuple, list)) and len(item) >= 3:
                audio = item[2]
            if audio is not None:
                if hasattr(audio, "numpy"):
                    audio = audio.numpy()
                segs.append(audio)
        if not segs:
            return None
        buf = io.BytesIO()
        sf.write(buf, np.concatenate(segs), 24000, format="WAV")
        buf.seek(0)
        return buf.read()
    except Exception as e:
        print(f"kokoro: {e}", file=sys.stderr)
        return None


def synth_repeat(text: str) -> bytes | None:
    """Repeated alerts: Kokoro Echo male, then Edge."""
    wav = synth_kokoro(text, KOKORO_VOICE)
    if wav:
        return wav
    return synth_edge(text)


def synth_once(text: str) -> bytes | None:
    """Unique summary: Edge TTS, then Kokoro, then none."""
    wav = synth_edge(text)
    if wav:
        return wav
    return synth_kokoro(text, KOKORO_VOICE)


def play_wav_bytes(wav: bytes) -> None:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        f.write(wav)
        path = f.name
    try:
        play_file(path)
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass


def play_file(path: str) -> None:
    if sys.platform == "darwin" and Path("/usr/bin/afplay").exists():
        subprocess.run(["/usr/bin/afplay", path], check=False)
        return
    try:
        import soundfile as sf
        import numpy as np

        # last resort: write and ffplay
        subprocess.run(["ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", path], check=False)
    except Exception:
        subprocess.run(["/usr/bin/say", f"played {Path(path).stem}"], check=False)


def mac_say(text: str) -> None:
    subprocess.run(["/usr/bin/say", "-v", "Daniel", text], check=False)


def clip_path(kind: str) -> Path:
    key = "need_help" if kind in ("help", "need_help") else kind
    return CLIPS / f"{key}.wav"


def bake(engine: str = "auto") -> None:
    CLIPS.mkdir(parents=True, exist_ok=True)
    use_k = engine == "kokoro" or (engine == "auto" and KOKORO_OK)
    print(f"baking clips engine={'kokoro '+KOKORO_VOICE if use_k else 'edge '+EDGE_VOICE}")
    for key, phrase in PHRASES.items():
        if key == "help":
            continue
        wav = synth_kokoro(phrase) if use_k else None
        if not wav:
            wav = synth_edge(phrase)
        if not wav:
            print(f"skip {key}")
            continue
        dest = CLIPS / f"{key}.wav"
        dest.write_bytes(wav)
        print(f"wrote {dest}")


def play_clip(kind: str) -> bool:
    path = clip_path(kind)
    if path.exists():
        play_file(str(path))
        return True
    phrase = PHRASES.get(kind) or PHRASES.get("ok")
    wav = synth_repeat(phrase)
    if wav:
        CLIPS.mkdir(parents=True, exist_ok=True)
        path.write_bytes(wav)
        play_file(str(path))
        return True
    mac_say(phrase)
    return True


def play_summary(text: str) -> None:
    text = " ".join(text.split())
    if not text:
        return
    CACHE.mkdir(parents=True, exist_ok=True)
    h = hashlib.md5(f"{EDGE_VOICE}:{text}".encode()).hexdigest()[:16]
    cached = CACHE / f"{h}.wav"
    if cached.exists():
        play_file(str(cached))
        return
    wav = synth_once(text)
    if wav:
        cached.write_bytes(wav)
        play_file(str(cached))
        return
    mac_say(text)


def main() -> int:
    p = argparse.ArgumentParser(description="Agent voice: clips + Edge summaries")
    p.add_argument(
        "kind",
        nargs="?",
        default="ok",
        help="done|ok|perfect|need_help|error|start|wait|bake|say",
    )
    p.add_argument("summary", nargs="*", help="optional one-off sentence (Edge TTS)")
    p.add_argument("--engine", choices=("auto", "kokoro", "edge"), default="auto")
    args = p.parse_args()
    kind = args.kind.replace("-", "_")
    summary = " ".join(args.summary).strip()

    if kind == "bake":
        bake(args.engine)
        return 0
    if kind == "say":
        if not summary:
            print("usage: notify.py say <text>", file=sys.stderr)
            return 2
        play_summary(summary)
        return 0

    if kind not in PHRASES and kind != "help":
        summary = " ".join([args.kind] + args.summary).strip()
        play_summary(summary)
        return 0

    play_clip(kind)
    if summary:
        play_summary(summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
