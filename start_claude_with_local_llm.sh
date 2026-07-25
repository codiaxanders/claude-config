
# Dessa fungerar sämre med Claude på RTX 5060 16GB
#export ANTHROPIC_MODEL=qwen2.5-coder:14b
#export ANTHROPIC_MODEL=glm-4.7-flash

# Funkar ok:
export ANTHROPIC_MODEL=gemma4:e4b-128k-fast

# Kanske bättre resonemang, men mindre context
#export ANTHROPIC_MODEL=gpt-oss:20b

export ANTHROPIC_BASE_URL=http://localhost:11434

export ANTHROPIC_SMALL_FAST_MODEL=gemma4:e4b-128k-fast 

claude

