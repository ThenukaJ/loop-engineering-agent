# Loop Engineering — Daily Triage Agent

> **Stop prompting. Design the loop. Get a score.**

This repo runs an autonomous **Daily Triage** loop powered by the [Loop Engineering](https://github.com/cobusgreyling/loop-engineering) framework.

## What It Does

Every day at 09:00 UTC, a GitHub Actions workflow triggers the `loop-triage` skill which:

1. **Scans** recent CI failures, open issues, and commits from the last 24h
2. **Triages** them into High Priority / Watch / Noise
3. **Updates** `STATE.md` with structured findings
4. **Commits** the updated state back to `main`
5. **Creates a GitHub issue** if any high-priority items need human attention

Week one is **L1 report-only** — no auto-fixes, just signal.

## Loop Ready Score

```
████████████████████  100/100  (L3)
```

## Files

| File | Purpose |
|------|---------|
| `LOOP.md` | Active loop configuration — pattern, cadence, gates |
| `STATE.md` | Durable memory — what the loop knows across runs |
| `loop-budget.md` | Daily token/run caps + kill switch |
| `loop-constraints.md` | Binding rules — path denylist, no auto-merge, max retries |
| `loop-run-log.md` | Append-only record of every run |
| `.claude/skills/loop-triage/` | Triage skill — inputs → structured report |
| `.claude/skills/loop-budget/` | Budget enforcement skill |
| `.claude/skills/loop-constraints/` | Constraint loader skill |
| `.claude/agents/loop-verifier.md` | Maker/checker — rejects unless tests pass |
| `.github/workflows/loop-triage.yml` | Scheduled daily triage Action |

## Architecture

```
Schedule (daily 09:00 UTC)
  → loop-triage skill reads CI/issues/commits
  → triage into High Priority / Watch / Noise
  → update STATE.md
  → commit state back to main
  → create GitHub issue if high-priority found
  → append to loop-run-log.md
```

## Promote Through Levels

| Level | What happens | When to promote |
|-------|-------------|-----------------|
| **L1** (now) | Report only — updates STATE.md | Week 1 |
| **L2** | Auto-fix in worktree + verifier + human gate | After L1 is consistently useful |
| **L3** | Full autonomous with explicit gates | After L2 verifier proves reliable |

## Kill Switch

Add the label `loop-pause-all` to any issue in this repo, or add the exact line `loop-pause-all` on its own in STATE.md. The loop exits immediately on the next run.

## License

MIT — scaffolded from [loop-engineering](https://github.com/cobusgreyling/loop-engineering) by Cobus Greyling.
