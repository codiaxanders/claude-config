
# Dessa fungerar sämre med Claude på RTX 5060 16GB
#export ANTHROPIC_MODEL=qwen2.5-coder:14b
#export ANTHROPIC_MODEL=glm-4.7-flash

# Funkar ok:på ett kort
#export ANTHROPIC_MODEL=gemma4:e4b-128k-fast

# Kanske bättre resonemang, men mindre context
#export ANTHROPIC_MODEL=gpt-oss:20b

# qwen2.5-coder skriver INTE ut korrekta tool-calls (saknar <tool_call>-taggar),
# Claude Code visar då rå JSON-text istället för att köra verktyget. Undvik.
#export ANTHROPIC_MODEL=qwen2.5-coder:32b-32k
#export ANTHROPIC_SMALL_FAST_MODEL=qwen2.5-coder:32b-32k

export ANTHROPIC_BASE_URL=http://localhost:11434

# qwen3-coder:30b-128k: bra på ren tool-calling (Bash/Read/Edit) men IGNORERAR
# superpowers-pluginet helt - kallar aldrig Skill-verktyget, varken vid
# implicita triggers (bugfix, "let's build X") eller explicit uppmaning
# (skriver då fel syntax, <function=Skill>..., som Ollama inte känner igen).
#export ANTHROPIC_MODEL=qwen3-coder:30b-128k
#export ANTHROPIC_SMALL_FAST_MODEL=qwen3-coder:30b-128k

# gemma4:31b-it-64k - testad bäst av 4 lokala modeller för Claude Code +
# superpowers (2026-08-06). Enda modellen som i alla 4 test (bugfix,
# explicit skill-call, implicit "let's build X", awareness) BÅDE kallade
# rätt Skill korrekt OCH fullföljde hela processen (t.ex. systematic-
# debugging: repro->root cause->fix->verify, testerna gick gröna).
# Bröt även ner brainstorming-skillets checklista i egna TaskCreate-poster,
# vilket är exakt vad using-superpowers-instruktionen ber om.
# Dense 31B (inte MoE) => mer VRAM/context än qwen3-coder, därför pinnad till
# 65536 context (27GB av 32GB, ~6GB marginal) istället för 131072 (bara
# ~2GB marginal, för riskabelt). Egen "ollama create"-tagg, se
# /tmp/gemma31b.modelfile för hur den byggdes.
export ANTHROPIC_MODEL=gemma4:31b-it-64k
#export ANTHROPIC_SMALL_FAST_MODEL=gemma4:31b-it-64k
export ANTHROPIC_SMALL_FAST_MODEL=qwen2.5-coder:3b-4k
claude

