---
name: close-session
description: End a work session by updating CURRENT-STATE, logs and a dated handoff summary so the next agent can resume from the repo alone. Use when the user types /close-session or says "wrap up", "I'm done", "end session", "update the handoff".
disable-model-invocation: true
---

# Close Session

1. **Summarize this session** for the session-closer, from the conversation:
   - Objective
   - What changed (files, PRs, commits)
   - Decisions made and why
   - Bugs found or fixed (symptom, root cause, fix)
   - What's verified vs unverified
   - Next steps
2. **Hand off** that summary to the **session-closer** subagent. It updates `ai/handoffs/CURRENT-STATE.md`, `ai/summaries/DECISION-LOG.md`, `ai/summaries/CRASH-AND-FIX-LOG.md`, writes `ai/summaries/YYYY-MM-DD-HHMM-<slug>.md`, and commits.
3. **Check for loose ends:** uncommitted changes (`git status`), unpushed commits, open PRs waiting on Zack, and whether production health was verified. List anything outstanding.
4. **Tell Zack:**
   ```
   Session closed. Docs: <files>  Commit/PR: <link>
   Outstanding: <items or "none">
   Next session, start with: "<exact first message>"
   ```
