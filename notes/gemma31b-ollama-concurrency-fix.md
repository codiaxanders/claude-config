# gemma4:31b-it-64k + Ollama concurrency fix (2026-08-08)

## Hardware (corrected)

Confirmed via `nvidia-smi`: **two** 16 GB GPUs, tensor-split, ~32 GB pooled
VRAM total — not a single 16 GB or 32 GB card. This is what the "27GB of
32GB" context-budget comment in `start_claude_with_local_llm.sh` refers to;
the older "RTX 5060 16GB" comment refers to one of the two cards.

## Problem

Testing `gemma4:31b-it-64k` + superpowers against a real project
(`crawler_test_procject_w_local_llm_for_claude`, a `.se` URL indexer) surfaced
two separate issues:

1. **Superpowers sub-agents are hardcoded to Anthropic model names** and
   don't work against Ollama at all. Workaround: run superpowers workflows
   sequentially (no sub-agent dispatch) instead of relying on `Agent`.
2. **Even sequential execution can trigger two concurrent calls to the same
   heavy model.** Patterns like "run a bash command, then monitor its
   status" made Claude Code fire two simultaneous requests to
   `gemma4:31b-it-64k` itself — not one to gemma and one to the small/fast
   `qwen2.5-coder:3b-4k` model. With `OLLAMA_NUM_PARALLEL` unset (effectively
   1), the second concurrent request forced GPU→CPU spillover (slow, and
   sometimes failed outright). The project's `PROJECT_STATUS.md` logged this
   as a "classifier crash" — misleading name, there is no classifier
   component in that project; it's just two concurrent calls to one dense
   31B model.

## Fix

In the ollama systemd override (`sudo systemctl edit ollama`):

```ini
[Service]
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_KV_CACHE_TYPE=q4_0"      # was q8_0
Environment="OLLAMA_KEEP_ALIVE=-1"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
Environment="OLLAMA_NUM_PARALLEL=2"          # was unset/1
```

Dropping KV cache precision from `q8_0` to `q4_0` freed enough VRAM headroom
for a second parallel KV-cache slot on the same dense model, without which
`OLLAMA_NUM_PARALLEL=2` would have pushed the second slot onto CPU.

`sudo systemctl daemon-reload && sudo systemctl restart ollama` to apply.

## Validation

**Concurrency fix:** fired 2 concurrent raw requests at
`http://localhost:11434/api/generate` for `gemma4:31b-it-64k`. Both completed
in parallel (~65s each — not serialized to ~130s), `ollama ps` reported
`100% GPU` before/during/after for both loaded models, VRAM usage
(~15.2GB / ~15.0GB per card) stayed flat throughout — no CPU offload.

**Quality regression check (q8_0 → q4_0):** the original model selection
(2026-08-06, see `start_claude_with_local_llm.sh` header comments) was based
on 4 informal tests: `bugfix`, `explicit skill-call`, `implicit "let's build
X"`, `awareness`. Those exact prompts weren't saved, so 4 representative
prompts were reconstructed and re-run headless (`claude -p --output-format
json --allowedTools "Read Write Edit Bash(pytest*) Bash(python*) Skill
TaskCreate TaskUpdate TaskList Glob Grep"` — note `--permission-mode
bypassPermissions` gets blocked by Claude Code's own safety classifier even
in a throwaway scratch dir; use a scoped `--allowedTools` list instead) in
isolated scratch directories under the new q4_0 config:

| Test | Skill invoked | Outcome |
|---|---|---|
| Bugfix (off-by-one in an average function) | `superpowers:systematic-debugging` | repro → root cause → fix → verify, correct fix |
| Explicit skill-call ("use the TDD skill...") | `superpowers:test-driven-development` | genuine RED→GREEN loop, test run after every edit |
| Implicit "let's build X" (word-frequency CLI) | `superpowers:brainstorming` (implicit) | checklist broken into TaskCreate entries, asked a clarifying question instead of guessing |
| Awareness (open-ended "how should I approach X") | `superpowers:brainstorming` (implicit) | same pattern, correctly asked for missing specifics |

All 4 preserved the exact behavior the original comparison was looking for.
**Conclusion: q4_0 KV cache quantization did not measurably degrade
skill-following/tool-calling quality for this model.** Downside observed was
speed, not correctness: 38–58 minutes of API time per test on the local 31B
model.

**Known untested edge case:** the concurrency test above used short prompts
(a few hundred tokens). Ollama/llama.cpp pre-allocates the persistent KV
cache for the full `num_ctx × num_parallel` budget at model load time (VRAM
usage was flat before/during/after the test, consistent with this), so KV
cache itself shouldn't grow with usage. But the transient compute/scratch
buffer used during prompt processing scales with how much context is
actually being processed in a batch — a real session near the 65536-token
ceiling with 2 requests in flight (long superpowers skill text + long tool
output, which is the actual crawler-project usage pattern) is a heavier
scenario than what was tested here. No failure expected based on the
architecture, but worth watching `ollama ps` / `nvidia-smi` during actual
long sessions rather than assuming the short-prompt test fully covers it.

## Current known-good config

```
ANTHROPIC_BASE_URL=http://localhost:11434
ANTHROPIC_MODEL=gemma4:31b-it-64k
ANTHROPIC_SMALL_FAST_MODEL=qwen2.5-coder:3b-4k
```

Ollama systemd env: `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q4_0`,
`OLLAMA_KEEP_ALIVE=-1`, `OLLAMA_MAX_LOADED_MODELS=2`, `OLLAMA_NUM_PARALLEL=2`.

If a third distinct model tag is ever added to the rotation (e.g. the
haiku/sonnet/opus model-name aliasing trick seen in one project's `tmp.txt`,
mapping different Ollama models to Anthropic model name strings so Claude
Code addresses them directly), raise `OLLAMA_MAX_LOADED_MODELS` accordingly —
otherwise expect load/unload thrashing between models.
