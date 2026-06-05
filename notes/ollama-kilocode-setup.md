# Local Ollama + Kilo Code Setup (ws1)

## Overview

Two models running permanently in VRAM on RTX 5060 Ti 16 GB:

| Role | Model | Context | VRAM |
|------|-------|---------|------|
| Default / agentic coding | `gemma4:e4b-128k` | 131072 | ~11 GB |
| Small / commit messages | `qwen2.5-coder:3b-4k` | 4096 | ~2.3 GB |

Total: ~13.3 GB, both 100% GPU, both kept loaded forever.

---

## 1. Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

---

## 2. Pull Base Models

```bash
ollama pull gemma4:e4b
ollama pull qwen2.5-coder:3b
```

---

## 3. Create Context-Baked Model Variants

The OpenAI-compatible endpoint Kilo uses cannot pass `num_ctx` per request,
so context is baked into named model variants via Modelfiles.

```bash
printf 'FROM gemma4:e4b\nPARAMETER num_ctx 131072\n' > /tmp/gemma4-128k.Modelfile
ollama create gemma4:e4b-128k -f /tmp/gemma4-128k.Modelfile

printf 'FROM qwen2.5-coder:3b\nPARAMETER num_ctx 4096\n' > /tmp/qwen3b-4k.Modelfile
ollama create qwen2.5-coder:3b-4k -f /tmp/qwen3b-4k.Modelfile
```

Verify:

```bash
ollama show gemma4:e4b-128k --modelfile
ollama show qwen2.5-coder:3b-4k --modelfile
```

---

## 4. Systemd Configuration

```bash
sudo systemctl edit ollama
```

Add the following in the designated section:

```ini
[Service]
# Context is baked per-model via Modelfiles; global default not needed
#Environment="OLLAMA_CONTEXT_LENGTH=131072"
#Environment="OLLAMA_CONTEXT_LENGTH=65536"
#Environment="OLLAMA_CONTEXT_LENGTH=28672"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"
Environment="OLLAMA_KEEP_ALIVE=-1"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
```

| Variable | Value | Effect |
|----------|-------|--------|
| `OLLAMA_FLASH_ATTENTION` | `1` | Faster attention, lower VRAM bandwidth usage |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Halves KV cache memory vs fp16, negligible quality loss |
| `OLLAMA_KEEP_ALIVE` | `-1` | Models stay loaded indefinitely, no reload delay |
| `OLLAMA_MAX_LOADED_MODELS` | `2` | Allows both models resident simultaneously |

Apply:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Verify env vars took effect:

```bash
systemctl show ollama --property=Environment
```

---

## 5. Verify Both Models Loaded

Trigger both models to load (e.g. send a message in Kilo, or via CLI),
then check:

```bash
ollama ps
```

Expected output:

```
NAME                   SIZE    PROCESSOR    CONTEXT    UNTIL
gemma4:e4b-128k        ~11 GB  100% GPU     131072     Forever
qwen2.5-coder:3b-4k    ~2.3 GB 100% GPU     4096       Forever
```

If UNTIL shows a timestamp instead of Forever, recheck the override file
at `/etc/systemd/system/ollama.service.d/override.conf`.

---

## 6. Kilo Code (VS Code Extension)

Install the Kilo Code extension, then open the Kilo panel → gear icon →
**Providers** tab.

### Add Custom Provider

Click **+ Connect** next to **Custom provider** and fill in:

| Field | Value |
|-------|-------|
| Base URL | `http://localhost:11434/v1` |
| API Key | `ollama` (required but ignored) |

### Add Models

Add two models in the model list:

| ID | Name | Reasoning |
|----|------|-----------|
| `gemma4:e4b-128k` | `gemma4:e4b-128k` | ✅ checked |
| `qwen2.5-coder:3b-4k` | `qwen2.5-coder:3b-4k` | ☐ unchecked |

### Model Assignments

Go to **Models** tab and set:

| Role | Model |
|------|-------|
| Default Model | `gemma4:e4b-128k` |
| Small Model | `qwen2.5-coder:3b-4k` |
| All per-mode rows | Not set (inherit Default) |

### Notes

- The **Reasoning** checkbox on gemma4 tells Kilo to parse and collapse
  the chain-of-thought into a separate block rather than mixing it into
  the response.
- The **Small Model** drives commit message generation, title generation,
  and prompt enhancement — kept at 4k context since it never needs more.
- Per-mode model rows (Code, Ask, Debug, etc.) are left unset so they
  all inherit the Default Model. Setting different large models per mode
  causes VRAM eviction since only one large model fits at a time.
- For agentic coding use **Code** mode; for plain conversation use
  **Ask** mode.

---

## 7. Hardware Notes (ws1)

- GPU: RTX 5060 Ti 16 GB
- OS: Ubuntu 26.04
- Both models fit at 100% GPU with ~0.6 GB headroom
- If a future model swap causes CPU spill, first lever is dropping
  `OLLAMA_KV_CACHE_TYPE` to `q4_0` (quarters cache vs fp16)
- On a GPU with 24 GB+, `OLLAMA_CONTEXT_LENGTH=131072` can be uncommented
  as the global default and Modelfiles may not be needed
