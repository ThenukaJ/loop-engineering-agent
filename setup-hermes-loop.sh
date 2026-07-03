#!/usr/bin/env bash
# Setup script: Run the Loop Engineering daily triage as a Hermes cron job

set -euo pipefail

echo "=== Setting up Loop Engineering with Hermes Agent ==="

# 1. Ensure skills are installed (they're in .claude/skills/ — copy to Hermes skills dir)
HERMES_SKILLS_DIR="${HERMES_HOME:-$HOME/.hermes}/skills"
mkdir -p "$HERMES_SKILLS_DIR"

echo "Installing loop skills to $HERMES_SKILLS_DIR..."
for skill in loop-triage loop-budget loop-constraints loop-implementer; do
  if [ -d ".claude/skills/$skill" ]; then
    cp -r ".claude/skills/$skill" "$HERMES_SKILLS_DIR/"
    echo "  ✓ $skill"
  fi
done

# Also install loop-verifier agent as a skill
if [ -f ".claude/agents/loop-verifier.md" ]; then
  mkdir -p "$HERMES_SKILLS_DIR/loop-verifier"
  cp ".claude/agents/loop-verifier.md" "$HERMES_SKILLS_DIR/loop-verifier/SKILL.md"
  echo "  ✓ loop-verifier"
fi

# 2. Write the prompt to a file (easier for long prompts)
cat > /tmp/hermes-loop-prompt.txt <<'PROMPT'
You are running the **Daily Triage Loop** (Loop Engineering pattern) for this repository.

### Your Skills (preloaded)
- `loop-triage` — produces structured triage report
- `loop-budget` — enforces token/run caps
- `loop-constraints` — loads binding rules from loop-constraints.md
- `loop-verifier` — maker/checker agent (rejects unless tests pass)

### Loop State
Read `STATE.md` at the start — it contains the durable memory from previous runs.

### Execute

1. **Check kill switch**: If `STATE.md` contains the exact line `loop-pause-all`, exit immediately.

2. **Gather context** (using terminal tool):
   - `gh run list --status failure --limit 20` (CI failures)
   - `gh issue list --state open --limit 20` (open issues)
   - `git log --oneline --since="48 hours ago" --max-count=20` (recent commits)

3. **Run triage** (apply loop-triage skill):
   - Classify into High Priority / Watch / Noise
   - Assign stable IDs: `ci-<run-id>`, `issue-<number>`
   - For each High Priority item, include: Title, Why, Type, Suggested Action, Effort (S/M/L), Files Likely Touched

4. **Update STATE.md** with the report (overwrite)

5. **Append to loop-run-log.md**: `| timestamp | L2 | high_count | watch_count | pass |`

6. **L2: For each High Priority item with Effort ≤ M and Type in {ci-failure, dependency}**:
   - Create isolated git worktree: `git worktree add ../loop-worktrees/fix-<id>-1 loop/fix/<id>-1`
   - In worktree, spawn implementer sub-agent with `loop-implementer` skill
   - After implementer commits, spawn `loop-verifier` sub-agent to check
   - If verifier APPROVES → create draft PR
   - If verifier REJECTS or ESCALATE_HUMAN → discard worktree, note in STATE.md

7. **Budget check**: If daily tokens > 160k (80% of 200k cap), switch to report-only and note in STATE.md

8. **Create GitHub issue** if any High Priority items found (label: `loop-triage,high-priority`)

9. **Commit STATE.md and loop-run-log.md** back to main

### Output
Return a brief summary: "Triage complete. X high, Y watch. Z PRs created." (or "Kill switch active — skipped")
PROMPT

# 3. Create the cron job (runs daily at 09:00 UTC)
# Pass the prompt file content as the positional argument
echo "Creating Hermes cron job..."
hermes cron create "0 9 * * *" "$(cat /tmp/hermes-loop-prompt.txt)" \
  --skill loop-triage \
  --skill loop-budget \
  --skill loop-constraints \
  --skill loop-implementer \
  --skill loop-verifier \
  --toolsets "terminal,file,web,delegation" \
  --name "loop-daily-triage" \
  --workdir "$(pwd -W)"

echo ""
echo "=== Done! ==="
echo ""
echo "Manage the job:"
echo "  hermes cron list"
echo "  hermes cron run loop-daily-triage   # test run now"
echo "  hermes cron pause loop-daily-triage # pause"
echo "  hermes cron remove loop-daily-triage # delete"
echo ""
echo "The job will run daily at 09:00 UTC in this directory,"
echo "using the skills from .claude/skills/ and STATE.md for memory."