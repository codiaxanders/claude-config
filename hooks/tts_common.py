import json, os, re, shutil, signal, subprocess, urllib.request, pathlib

BASE = pathlib.Path.home() / ".claude" / "tts"
CONFIG = BASE / "config.json"
CATALOG = BASE / "voices.json"
VOICES = pathlib.Path.home() / ".local/share/piper"
VOICE_URL = "https://huggingface.co/rhasspy/piper-voices/resolve/main"
DEFAULT_VOICE = {"sv": "sv_SE-nst-medium", "en": "en_US-lessac-medium"}
LANGS = tuple(DEFAULT_VOICE)


def load_config():
    try:
        return json.loads(CONFIG.read_text())
    except (OSError, ValueError):
        return {}


def save_config(cfg):
    BASE.mkdir(parents=True, exist_ok=True)
    CONFIG.write_text(json.dumps(cfg, indent=2) + "\n")


def piper_path():
    found = shutil.which("piper")
    if found:
        return found
    local = os.path.expanduser("~/.local/bin/piper")
    return local if os.path.exists(local) else None


def installed(name):
    return (VOICES / f"{name}.onnx").exists() and (VOICES / f"{name}.onnx.json").exists()


def installed_voices(lang):
    return sorted(p.name[:-len(".onnx.json")] for p in VOICES.glob(f"{lang}_*.onnx.json")
                  if (VOICES / p.name[:-len(".json")]).exists())


def voice_lang(name):
    return name.split("_", 1)[0]


def voice_url_dir(name):
    """en_GB-northern_english_male-medium -> en/en_GB/northern_english_male/medium"""
    locale, speaker, quality = name.split("-", 2)
    return f"{voice_lang(name)}/{locale}/{speaker}/{quality}"


def download_cmd(name):
    files = f"{name}.onnx {name}.onnx.json"
    return (f"mkdir -p ~/.local/share/piper && cd ~/.local/share/piper && "
            f"for f in {files}; do curl -fLO {VOICE_URL}/{voice_url_dir(name)}/$f; done")


def catalog():
    """Single-speaker sv/en voices from Piper's catalog, cached locally."""
    if not CATALOG.exists():
        BASE.mkdir(parents=True, exist_ok=True)
        try:
            with urllib.request.urlopen(f"{VOICE_URL}/voices.json", timeout=10) as r:
                CATALOG.write_bytes(r.read())
        except OSError:
            return []
    try:
        data = json.loads(CATALOG.read_text())
    except ValueError:
        return []
    return sorted(k for k, v in data.items()
                  if v["language"]["family"] in LANGS and v.get("num_speakers", 1) == 1)


def resolve_voice(query):
    """Match a full voice name or a short form like 'alma' or 'ryan-high'."""
    names = sorted(set(catalog()) | set(installed_voices("sv")) | set(installed_voices("en")))
    if query in names:
        return [query]
    hits = [n for n in names if f"-{query}" in n]
    medium = [n for n in hits if n.endswith("-medium")]
    return medium if len(medium) == 1 else hits


def current_voice(cfg, lang):
    """Configured voice for lang, falling back to the default or any installed voice."""
    for name in (cfg.get(f"voice_{lang}"), DEFAULT_VOICE[lang]):
        if name and installed(name):
            return name
    others = installed_voices(lang)
    return others[0] if others else None


def sample_rate(name):
    try:
        with open(VOICES / f"{name}.onnx.json") as f:
            return int(json.load(f)["audio"]["sample_rate"])
    except (OSError, ValueError, KeyError):
        return 22050


def speak(text, voice, cfg, pidfile=None):
    """Start playback in its own process group; stop any previous one in pidfile."""
    if pidfile:
        stop(pidfile, unlink=False)
    piper = piper_path()
    if piper and voice and shutil.which("aplay"):
        scale = round(1 / float(cfg.get("speed", 1.0)), 3)
        cmd = (f'"{piper}" --model "{VOICES / voice}.onnx" --length-scale {scale} --output-raw 2>/dev/null'
               f" | aplay -q -r {sample_rate(voice)} -f S16_LE -t raw -")
    else:
        wpm = int(175 * float(cfg.get("speed", 1.0)))
        cmd = f"espeak-ng -v {voice_lang(voice) if voice else 'sv'} -s {wpm} --stdin"
    proc = subprocess.Popen(["sh", "-c", cmd], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL, start_new_session=True)
    if pidfile:
        pidfile.write_text(str(proc.pid))
    proc.stdin.write(text.encode())
    proc.stdin.close()


def stop(pidfile, unlink=True):
    try:
        os.killpg(int(pidfile.read_text()), signal.SIGTERM)
    except (OSError, ValueError):
        pass
    if unlink:
        pidfile.unlink(missing_ok=True)


def is_running(pidfile):
    try:
        os.killpg(int(pidfile.read_text()), 0)
        return True
    except (OSError, ValueError):
        return False


SV_WORDS = {"och", "att", "det", "som", "är", "en", "jag", "du", "inte", "för", "med", "på", "har", "kan", "ska"}
EN_WORDS = {"the", "and", "to", "is", "of", "you", "it", "that", "for", "with", "on", "are", "can", "this", "be"}


def detect_lang(text):
    words = re.findall(r"[a-zåäö]+", text.lower())
    sv = sum(w in SV_WORDS for w in words) + 2 * len(re.findall(r"[åäö]", text.lower()))
    en = sum(w in EN_WORDS for w in words)
    return "en" if en > sv else "sv"
