---
name: feedback_reexamine_diagnosis_when_fix_fails
description: When a proposed fix for a bug doesn't work, re-examine the underlying diagnosis before intensifying the same fix — don't just turn the same knob harder
metadata:
  type: feedback
---

When a fix for an error doesn't resolve it, treat that as evidence the
diagnosis itself may be wrong — not just evidence the fix needs to be
stronger. Stop and re-derive the failure mode from the actual error
text/traceback before proposing another variant of the same fix.

**Why:** While debugging a Ubuntu autoinstall failure
(`AutoinstallError: ... matched no disk`) for the [[zipfer-server-project]]
work, Claude diagnosed it as a udev-symlink timing race and added
`udevadm settle`. When that didn't help, Claude "intensified" the same
theory — added `sleep 15` and a longer timeout — still without
questioning whether the race theory was correct at all. The user
pushed back ("jag tycker det låter konstigt... jag tror du är fel
ute"), which prompted a real re-read of the traceback
(`subiquity/models/filesystem.py`, `convert_autoinstall_config`) and
the actual root cause: curtin's disk-matching compares against each
probed disk's canonical `/dev/sdX`, not a `/dev/disk/by-id/...` alias
— so the `path:` field with a by-id string could never match,
regardless of any timing fix. Two rounds of user time and photographed
terminal screenshots were spent chasing the wrong theory before this
came out — evidence (timestamps showing the probe ran only ~9s after
subiquity started) was actually available earlier and was used to
*confirm* the race theory rather than to *test* it against
alternatives.

**How to apply:**
- After a fix attempt fails, before proposing a stronger version of
  the same fix, ask: does the exact error text/traceback actually
  support this mechanism, or does it just not contradict it? "Doesn't
  contradict" is not the same as "supports."
- Look for a more specific, more mechanical explanation from the
  actual code path in the traceback (function/line) before reaching
  for environment-timing explanations, which are a common but lazy
  default when the true cause is a config/schema mismatch.
- Take "that sounds wrong" pushback from the user seriously and
  literally restart the diagnosis from the raw evidence, rather than
  defending or lightly adjusting the standing theory.
- This generalizes beyond this one project — applies to any
  systematic-debugging situation.
