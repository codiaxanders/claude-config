#!/usr/bin/env python3
import json, re, shutil, subprocess, sys, urllib.request

from tts_common import (BASE, CONFIG, DEFAULT_VOICE, LANGS, VOICE_URL, VOICES, catalog, current_voice,
                        download_cmd, installed, installed_voices, is_running, load_config, piper_path,
                        resolve_voice, save_config, speak, stop, voice_lang, voice_url_dir)

SPEED_STEP = 0.1
SPEED_MIN, SPEED_MAX = 0.5, 2.5
SAMPLE = {"sv": "Hej, det här är rösten {}.", "en": "Hello, this is the voice {}."}

HELP = """Kommandon:
  tts on | tts off           slå på/av uppläsning i denna session
  tts status                 visa läge, röster och inställningar
  tts faster | tts slower    ändra hastighet ett steg
  tts speed 1.3              sätt hastighet (0.5–2.5, 1.0 = normal)
  tts voice                  lista röster
  tts voice <namn>           välj röst, t.ex. tts voice alma (laddas ner vid behov)
  tts test [sv|en]           läs upp ett prov med vald röst"""


def check_tools():
    """Return (usable, list of problems with fix commands)."""
    problems = []
    piper, aplay = piper_path(), shutil.which("aplay")
    if not piper:
        problems.append("piper saknas:\n  sudo apt install pipx && pipx install piper-tts")
    if not aplay:
        problems.append("aplay saknas:\n  sudo apt install alsa-utils")
    for lang in LANGS:
        if not installed_voices(lang):
            problems.append(f"Ingen {lang}-röst installerad:\n  {download_cmd(DEFAULT_VOICE[lang])}")
    espeak = shutil.which("espeak-ng")
    if not espeak:
        problems.append("espeak-ng saknas (reserv om Piper inte fungerar):\n  sudo apt install espeak-ng")
    usable = bool((piper and aplay and installed_voices("sv")) or espeak)
    return usable, problems


def set_speed(cfg, speed):
    cfg["speed"] = round(min(SPEED_MAX, max(SPEED_MIN, speed)), 2)
    save_config(cfg)
    return f"Uppläsningshastighet: {cfg['speed']} (1.0 = normal)"


def play_sample(name, cfg):
    speak(SAMPLE[voice_lang(name)].format(name.split("-")[1]), name, cfg, BASE / "sample.pid")


def fetch_voice(name):
    """Runs detached: download a voice, then play a sample with it."""
    VOICES.mkdir(parents=True, exist_ok=True)
    for f in (f"{name}.onnx.json", f"{name}.onnx"):
        part = VOICES / (f + ".part")
        with urllib.request.urlopen(f"{VOICE_URL}/{voice_url_dir(name)}/{f}", timeout=60) as r:
            part.write_bytes(r.read())
        part.rename(VOICES / f)
    play_sample(name, load_config())


def list_voices(cfg):
    lines = []
    for lang in LANGS:
        have = installed_voices(lang)
        lines.append(f"{lang}: vald {current_voice(cfg, lang) or '–'}")
        lines.append("  installerade: " + (", ".join(have) or "–"))
        more = [n for n in catalog() if voice_lang(n) == lang and n not in have]
        if more:
            lines.append("  kan laddas ner: " + ", ".join(more))
    lines.append("Välj med t.ex. tts voice alma eller tts voice en_GB-alan-medium")
    return "\n".join(lines)


def choose_voice(cfg, query):
    hits = resolve_voice(query)
    if not hits:
        return f"Hittar ingen röst som matchar \"{query}\". Se tts voice"
    if len(hits) > 1:
        return f"Flera röster matchar \"{query}\": " + ", ".join(hits)
    name = hits[0]
    cfg[f"voice_{voice_lang(name)}"] = name
    save_config(cfg)
    if installed(name):
        play_sample(name, cfg)
        return f"Röst för {voice_lang(name)}: {name}"
    subprocess.Popen([sys.executable, __file__, "--fetch", name], start_new_session=True,
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return f"Röst för {voice_lang(name)}: {name}. Laddas ner nu (ca 60 MB), ett prov spelas upp när den är klar."


def status(sid, cfg):
    lines = [
        f"Uppläsning i denna session: {'PÅ' if (BASE / sid).exists() else 'AV'}"
        + (" (läser upp just nu)" if is_running(BASE / (sid + ".pid")) else ""),
        f"Hastighet: {cfg.get('speed', 1.0)} (1.0 = normal)",
    ]
    lines += [f"Röst {lang}: {current_voice(cfg, lang) or '–'}" for lang in LANGS]
    lines += [
        "Språkval: automatiskt per svar (svenska/engelska)",
        f"Max tecken per svar: {cfg.get('max_chars', 2000)}",
        f"Inställningar: {CONFIG}",
        HELP,
    ]
    problems = check_tools()[1]
    if problems:
        lines += ["", "Saknas på denna maskin:"] + problems
    return "\n".join(lines)


def handle(cmd, arg, sid):
    cfg = load_config()
    flag = BASE / sid
    if cmd == "on":
        usable, problems = check_tools()
        report = "\n\nSaknas på denna maskin:\n" + "\n".join(problems) if problems else ""
        if not usable:
            return "Uppläsning kan inte slås på, inget fungerande talverktyg." + report
        flag.touch()
        return f"Uppläsning PÅ för denna session (hastighet {cfg.get('speed', 1.0)})" + report
    if cmd == "off":
        flag.unlink(missing_ok=True)
        stop(BASE / (sid + ".pid"))
        return "Uppläsning AV"
    if cmd == "status":
        return status(sid, cfg)
    if cmd == "faster":
        return set_speed(cfg, cfg.get("speed", 1.0) + SPEED_STEP)
    if cmd == "slower":
        return set_speed(cfg, cfg.get("speed", 1.0) - SPEED_STEP)
    if cmd == "speed":
        try:
            return set_speed(cfg, float(arg.replace(",", ".")))
        except ValueError:
            return "Ange fart som tal, t.ex. tts speed 1.2"
    if cmd == "voice":
        return choose_voice(cfg, arg) if arg else list_voices(cfg)
    if cmd == "test":
        name = current_voice(cfg, arg if arg in LANGS else "sv")
        if not name:
            return "Ingen röst installerad för det språket"
        play_sample(name, cfg)
        return f"Spelar prov med {name}"
    return HELP


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--fetch":
        fetch_voice(sys.argv[2])
        return
    d = json.load(sys.stdin)
    sid = d["session_id"]
    prompt = re.sub(r"[.!?]+$", "", d.get("prompt", "").strip().lower())
    m = re.fullmatch(r"tts(?:\s+(\S+))?(?:\s+(\S+))?", prompt)
    if not m:
        if (BASE / sid).exists():
            stop(BASE / (sid + ".pid"))
        return
    BASE.mkdir(parents=True, exist_ok=True)
    msg = handle(m.group(1) or "status", m.group(2) or "", sid)
    print(json.dumps({"decision": "block", "reason": msg}))


main()
