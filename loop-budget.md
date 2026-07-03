# Loop Budget — loop-engineering-agent

> Primary loop: **Daily Triage** (L2 auto-fix)

## Daily Limits

| Loop | Max runs/day | Max tokens/day | Max sub-agent spawns/run |
|------|--------------|----------------|--------------------------|
| Daily Triage | 2 | 200k | 2 (implementer + verifier) |

## Per-Item Limits

- Max implementer attempts per item: **3**
- Max verifier retries per attempt: **1**
- Max worktree lifetime: **30 minutes** (auto-cleanup)

## On Budget Exceed

1. Pause schedulers (`scheduler_delete` or disable automations)
2. Append event to `loop-run-log.md`
3. Notify human (Slack / issue / STATE.md High Priority)
4. Switch to **report-only (L1)** until human resets

## Kill Switch

- Command or issue label: `loop-pause-all`
- Resume only after human clears the flag in STATE.md

## Estimate Spend

```bash
npx @cobusgreyling/loop-cost --pattern daily-triage --level L2
```