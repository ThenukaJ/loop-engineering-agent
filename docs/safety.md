# Safety Policy — Loop Engineering

> This file is read by the loop at the start of every run.
> It is **binding** — the agent MUST follow these rules.

## Auto-merge Policy

- **Never** auto-merge to `main` without human approval
- All fixes must go through a **draft PR** first
- PR is marked ready only after human review
- Loop may add comments to PRs but may not approve or merge

## Path Denylist

The loop MUST NOT edit any of the following:

- `.env`, `.env.*` — environment secrets
- `auth/`, `credentials/` — authentication files
- `payments/` — payment processing logic
- `secrets/` — secret material
- `.github/workflows/` — CI/CD configuration (only the loop's own workflow may be edited by a human)
- `terraform/`, `infrastructure/` — infrastructure-as-code

## MCP Connector Scopes

| Connector | Allowed scopes | Denied scopes |
|-----------|---------------|---------------|
| GitHub | `read`, `comment`, `create-issue`, `create-pr` | `merge`, `delete`, `admin` |
| Linear | `read`, `comment` | `write`, `delete` |
| Slack | `read`, `post` to `#ops-loop` only | `post` to general channels |

## Risk Classification

| Risk level | Examples | Action |
|-----------|---------|--------|
| **Low** | Docs, comments, lint fixes | Loop may act (L2+) |
| **Medium** | Dependency patch, test fix | Loop acts + verifier + human gate |
| **High** | Logic change, schema migration, config | Human only — loop reports |
| **Critical** | Auth, payments, data migration | Human only — loop creates issue + pings |

## Kill Switches

| Signal | How to activate | Effect |
|--------|----------------|--------|
| `loop-pause-all` | Add as issue label OR set in STATE.md | Loop exits immediately on next run |
| Budget breach (80%) | Automatic via loop-budget skill | Loop switches to report-only |
| Verifier ESCALATE_HUMAN | Returned by loop-verifier agent | Worktree discarded, human notified |

## Incident Response

If the loop produces a broken or risky change:

1. Revert the commit / close the PR
2. Add `loop-pause-all` label to stop future runs
3. Add a constraint to `loop-constraints.md` to prevent recurrence
4. Remove the label to resume
