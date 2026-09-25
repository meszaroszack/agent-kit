---
name: ship
description: Take finished work from a branch to verified-live — tests, review, PR, CI, merge, Railway deploy, live health check. Use when the user types /ship or says "ship it", "open a PR", "let's deploy this".
disable-model-invocation: true
---

# Ship

Moves the current branch from "code written" to "verified in production". Stop at any failed gate and report.

## Gates

```
- [ ] 1. Branch is up to date with origin/main
- [ ] 2. Local checks pass
- [ ] 3. Tests cover the change
- [ ] 4. Review verdict is SHIP
- [ ] 5. PR open, CI green
- [ ] 6. Merged (only with Zack's go-ahead)
- [ ] 7. Deployed and verified live
- [ ] 8. Docs and handoff updated
```

1. **Up to date:** `git fetch origin && git rebase origin/main`. Resolve conflicts; if the conflict touches logic you didn't write, stop and ask.
2. **Local checks:** run the repo's commands from `AGENTS.md` (typically `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`, or `ruff check .` and `pytest`). Paste the pass/fail summary.
3. **Tests:** if logic changed without tests, hand off to the **test-engineer** subagent.
4. **Review:** hand off to the **reviewer** subagent. Fix everything under "Critical", then re-run step 2.
5. **PR:** push the branch and open a PR against `main` with `gh pr create`. Use the repo's PR template: what changed, why, evidence (check output), deploy implications, docs updated. Wait for CI: `gh pr checks --watch`. If CI fails, fix and push.
6. **Merge:** ask Zack before merging unless he already said to. Use `gh pr merge --squash --delete-branch`.
7. **Deploy and verify:** hand off to the **railway-deployer** subagent. Don't claim success without its live health check result.
8. **Docs:** hand off to the **session-closer** subagent, or update CURRENT-STATE directly if this is mid-session.

## Final report

```
PR: <link>   CI: green   Merged: <sha>
Live: <url> — <health result>
Docs: <files updated>
```
