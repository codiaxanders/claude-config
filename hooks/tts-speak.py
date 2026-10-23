#!/usr/bin/env python3
import json, os, re, sys, time

from tts_common import BASE, current_voice, detect_lang, load_config, speak


def last_text(d):
    lam = d.get("last_assistant_message")
    if isinstance(lam, str) and lam.strip():
        return lam
    for _ in range(25):
        time.sleep(0.2)
        texts = []
        with open(d["transcript_path"]) as f:
            lines = f.read().splitlines()
        for line in reversed(lines):
            try:
                e = json.loads(line)
            except ValueError:
                continue
            t = e.get("type")
            c = (e.get("message") or {}).get("content")
            if t == "user":
                if isinstance(c, str) or any(isinstance(b, dict) and b.get("type") == "text" for b in (c or [])):
                    break
                continue
            if t == "assistant" and isinstance(c, list):
                for b in reversed(c):
                    if isinstance(b, dict) and b.get("type") == "text":
                        texts.insert(0, b["text"])
        if texts:
            return "\n".join(texts)
    return ""


def clean(text, limit):
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"^[ \t]*\|?[ \t]*:?-{3,}.*$", "", text, flags=re.M)
    text = re.sub(r"^[ \t]*\|(.*)\|[ \t]*$", lambda m: m.group(1).replace("|", ",").strip() + ".", text, flags=re.M)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"https?://\S+", "länk", text)
    text = re.sub(r"`?(?:~|\.{0,2})?/[\w.\-/<>]+/([\w.\-<>]+)`?", r"\1", text)
    text = re.sub(r"[\U0001F000-\U0001FFFF☀-➿️]", "", text)
    text = re.sub(r"[`*_#>|]", "", text)
    text = re.sub(r"\n{2,}", "\n", text).strip()
    if len(text) > limit:
        cut = text.rfind(".", 0, limit)
        text = text[: cut + 1 if cut > limit // 2 else limit]
    return text


def main():
    d = json.load(sys.stdin)
    sid = d.get("session_id", "")
    if not sid or not (BASE / sid).exists():
        return
    cfg = load_config()
    text = clean(last_text(d), int(cfg.get("max_chars", 2000)))
    if os.environ.get("TTS_DEBUG"):
        with open(BASE / "log", "a") as f:
            f.write(f"{time.ctime()} len={len(text)} lam={'last_assistant_message' in d}\n")
    if text:
        speak(text, current_voice(cfg, detect_lang(text)), cfg, BASE / (sid + ".pid"))


main()
