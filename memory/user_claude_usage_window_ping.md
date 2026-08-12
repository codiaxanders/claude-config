---
name: user-claude-usage-window-ping
description: "User schedules a claude -p \"ping\" cron job on erdinger at 05/10/15 to open three fresh 5-hour usage windows per workday"
metadata: 
  node_type: memory
  type: user
  originSessionId: e759ded4-21bd-4609-9f72-684244674bbc
  modified: 2026-08-12
---

Anders runs a cron job on the host `erdinger` that pings `claude -p "ping"` at 05:00, 10:00, and 15:00 daily (`0 5,10,15 * * * CLAUDE_PING_MODE=true PATH=$PATH:/usr/local/bin:/usr/bin /home/anders/.local/bin/claude -p "ping" >> /tmp/claude_ping.log 2>&1`).

Note: as of 2026-08-12 the crontab invokes the binary via its full path (`/home/anders/.local/bin/claude`) rather than bare `claude` — likely to avoid relying on PATH resolution under cron's minimal environment.

This is intentional, not a leftover test or monitoring heartbeat: Claude Code usage is metered in rolling 5-hour windows/quotas. By triggering a ping at the start of each of those three times, he opens three separate 5-hour windows spaced through a workday, maximizing the usage capacity available to him during working hours.

**How to apply:** if this crontab entry or `CLAUDE_PING_MODE` comes up again, don't guess at its purpose — it's a deliberate usage-window/quota management trick, not a smoke test or keepalive.
