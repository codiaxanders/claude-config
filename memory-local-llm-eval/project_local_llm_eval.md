---
name: project-local-llm-eval
description: Status of evaluating local ollama models as Claude Code backends
metadata: 
  node_type: memory
  type: project
  originSessionId: 5038e60c-c6dd-4aab-bd99-6caf418ea441
  modified: 2026-08-09T19:48:22.547Z
---

Current pick (as of 2026-08-06 per script comments): `gemma4:31b-it-64k`, a custom `ollama create` tag built from a Modelfile at `/tmp/gemma31b.modelfile`, pinned to 65536 context (~27GB/32GB VRAM, ~6GB margin) rather than 131072 (too tight at ~2GB margin). Small/fast model paired with it: `qwen2.5-coder:3b-4k`.

**Why this model:** it's the only one of 4 candidates that, across all 4 tests (bugfix, explicit skill-call, implicit "let's build X", awareness), both invoked the correct superpowers Skill AND completed the full expected process (e.g. systematic-debugging: repro → root cause → fix → verify, tests green). It also broke down the brainstorming skill's checklist into its own TaskCreate entries, matching what the using-superpowers instructions ask for.

Models tried and rejected, per comments in `start_claude_with_local_llm.sh` (see [[reference-claude-config-repo]]):
- `qwen2.5-coder:14b`, `glm-4.7-flash` — worse on RTX 5060 16GB.
- `gemma4:e4b-128k-fast` — ok but not chosen.
- `gpt-oss:20b` — maybe better reasoning, less context.
- `qwen2.5-coder:32b-32k` — does not emit correct `<tool_call>` tags; Claude Code shows raw JSON instead of running tools. Avoid.
- `qwen3-coder:30b-128k` — good raw tool-calling but completely ignores the superpowers plugin (never calls the Skill tool, implicit or explicit; on explicit request emits invalid `<function=Skill>...` syntax Ollama doesn't understand).

**How to apply:** when discussing local-model choice or debugging why a local model isn't invoking Skills/tools correctly in this setup, lead with `gemma4:31b-it-64k` as the validated default and check the rejection reasons above before re-suggesting a rejected model.

Hardware: confirmed via `nvidia-smi` (2026-08-08) as **two** 16GB GPUs (~32GB pooled total, tensor-split), not a single 16GB or 32GB card — resolves earlier ambiguity between the "RTX 5060 16GB" script comment and the "27GB of 32GB" context-budget note. The older `ollama-kilocode-setup.md` doc used a different host ("ws1", RTX 5060 Ti) and a different model pair for the Kilo Code extension, not Claude Code — don't conflate the two setups.

**Superpowers + Ollama concurrency issue (found/fixed 2026-08-08):** running superpowers workflows (e.g. `executing-plans`, systematic-debugging with background bash) in the [[project-crawler-se-indexer]] project made Claude Code fire two concurrent calls to the *same* heavy model (`gemma4:31b-it-64k`). With `OLLAMA_NUM_PARALLEL=1` this caused GPU→CPU spillover. Fix applied: `OLLAMA_KV_CACHE_TYPE=q4_0` (down from `q8_0`) + `OLLAMA_NUM_PARALLEL=2` in the ollama systemd override, freeing enough VRAM headroom for a second parallel KV cache slot on the same dense 31B model. Correction to earlier note: the "classifier" in the project's status doc was **not** a red herring — see [[project-claude-code-automode-local-backend]] for the real mechanism (Claude Code's own auto-mode safety classifier), found 2026-08-09.

Validated 2026-08-08: fired 2 concurrent raw API requests at gemma4:31b-it-64k — both completed in parallel (~65s each, not serialized), `ollama ps` stayed 100% GPU throughout, no CPU offload. Then re-ran 4 reconstructed versions of the original validation categories (bugfix, explicit skill-call, implicit "let's build X", awareness) headless via `claude -p --allowedTools ...` under the new q4_0 config — all 4 still correctly invoked the matching superpowers skill (systematic-debugging, test-driven-development, brainstorming x2) and completed/paused appropriately (genuine RED-GREEN TDD cycle observed, correct bugfix with repro→fix→verify, correct implicit-brainstorming trigger twice). **Conclusion: q4_0 KV cache quantization does not appear to have degraded skill-following quality for this model** — safe to keep.

Hardware correction (2026-08-09, confirmed via `ggml_cuda_init` ollama journal log): it's **2× NVIDIA RTX 5060 Ti** (each 15.9 GiB), not a base "RTX 5060" — supersedes the 2026-08-08 note above.

**2026-08-09: found and fixed the real remaining blocker** — Claude Code's own auto-mode Bash-safety classifier (not Ollama concurrency) was the actual cause of persistent "temporarily unavailable" errors in the crawler project. Full details, root cause, what works and what doesn't, and the current validated config: see [[project-claude-code-automode-local-backend]]. As of this date the crawler project's Plans 1–3 all build/verify cleanly end-to-end (confirmed via two independent real runs) using that config.
