---
name: kickoff
description: Start a work session in a repo by loading state, checking git health, and agreeing on one clear objective. Use when the user types /kickoff, says "let's start", "where did we leave off", or opens a repo to begin work.
disable-model-invocation: true
---

# Kickoff

Get oriented in under two minutes, then agree on the session's objective.

## Steps

1. **Git health**
   ```
   git fetch --all --prune
   git status -sb
   git log origin/main -5 --oneline
   git rev-list --left-right --count origin/main...HEAD
   ```
   Flag uncommitted changes, being behind `origin/main`, or being on a stale feature branch.

2. **Read state** (skip missing files and note them):
   - `AGENTS.md`
   - `ai/handoffs/CURRENT-STATE.md`
   - The newest file in `ai/summaries/` (by filename date)
   - The "Hard Rules" section of `ai/summaries/CRASH-AND-FIX-LOG.md`

3. **Open work:** `gh pr list --state open` and `gh issue list --limit 10`, if `gh` is available.

4. **Production health** (if CURRENT-STATE lists a live URL): request the health endpoint and report the status.

5. **Report to Zack** in this shape:
   ```
   Repo: <name>   Branch: <branch> (<n> behind / <m> ahead of main)
   Live: <url> — <health>
   Last session: <one line from latest summary>
   Open: <PRs / top open items>
   Suggested objective: <one sentence, from CURRENT-STATE next steps>
   ```

6. **Agree on one objective.** If the work is large or ambiguous, suggest handing it to the architect subagent (or switching to Plan mode) first. Then create a branch: `git checkout -b <type>/<short-name> origin/main`.

If the repo has no `AGENTS.md` or `ai/` folder, say so and offer the `bootstrap-repo` skill.
