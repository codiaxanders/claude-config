---
name: feedback-limit-parallel-agents
description: No fixed cap on parallel subagents since 2026-11-27; maximise throughput, flag runaway usage, stop all on "pausa"
metadata:
  type: feedback
---

Since 2026-11-27 (plan upgrade) there is no fixed limit on parallel subagents. Anders wants to work as efficiently and productively as possible and expects to have more quota than he easily uses over the coming months. This replaces the earlier one-agent-at-a-time rule from 2026-11-23.

**Why:** He now has much more capacity and would rather use it for throughput. The earlier limit came from 9 parallel agents burning tokens faster than he could react.

**How to apply:** Fan out to parallel agents whenever the work splits into independent parts, and choose the scale by usefulness, not by caution. Say briefly how many are running. Point it out if something looks like it is running away (unusually long, many rounds, agents spawning agents), and he will set a limit then. Stop all agents immediately on "pausa".
