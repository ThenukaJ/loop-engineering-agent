# Loop Configuration — Daily Triage (L2 Auto-fix)

## Active Loops

| Pattern | Cadence | Status | Command |
|---------|---------|--------|---------|
| Daily Triage | 1d | **L2 auto-fix** | `/loop 1d $loop-triage` → spawns implementer + verifier |

## Human Gates

- All fixes go through **draft PR** → **verifier check** → **human review** → **merge**
- No auto-merge to `main` without human approval
- High-risk paths (see `docs/safety.md`): always require human review even if tests pass
- Verifier `ESCALATE_HUMAN` verdict → worktree discarded, issue created for human

## Worktrees

- **Isolation**: `worktree` for every implementer spawn
- **Location**: `../loop-worktrees/fix-<item-id>-<attempt>`
- **Branch**: `loop/fix/<item-id>-<attempt>`
- **Lifecycle**: Created per fix attempt; discarded on REJECT; merged via PR on APPROVE
- **Max concurrent**: 2 (see budget)

## Connectors (MCP)

- **GitHub MCP**: read CI, issues, PRs; create PRs, comment; scope: `read`, `comment`, `create-pr`
- **Linear MCP** (optional): read tickets; scope: `read`, `comment`
- **Slack MCP** (optional): post to `#ops-loop` only
- All connectors **read-only until trusted**; write scopes enabled after L2 validation

## Budget

- Max sub-agent spawns per run: **2** (implementer + verifier)
- Max implementer retries per item: **3** (then ESCALATE_HUMAN)
- Daily token cap: **200k** (L2)
- On budget exceed (80%): switch to report-only, notify human

## Links

- Pattern: [daily-triage](https://github.com/cobusgreyling/loop-engineering/blob/main/patterns/daily-triage.md)
- Checklist: [loop-design-checklist](https://github.com/cobusgreyling/loop-engineering/blob/main/docs/loop-design-checklist.md)
- Safety: [docs/safety.md](docs/safety.md)
- Constraints: [loop-constraints.md](loop-constraints.md)
- Budget: [loop-budget.md](loop-budget.md)