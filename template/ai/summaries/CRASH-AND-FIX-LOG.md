# Crash and Fix Log

Every bug found or fixed, with root cause. Read **Hard Rules** before writing code.

## Hard Rules

One line per lesson learned. Agents must check changes against these.

- Start the HTTP server and health endpoint before slow boot work (Railway healthcheck).
- State that must survive a redeploy goes in the database or a mounted volume, never container disk or memory.
- One implementation of each external auth/signing scheme, with a test against a known-good value. Never re-implement it in another file.
- The typecheck script must cover every TypeScript project (server and client).
- External API responses can be null, empty, stale or renamed: handle it and log it; never silently skip critical logic.

## Pattern index

| Pattern | Entries |
|---|---|
| <e.g. Auth/signing> | CRASH-<NNN> |

---

## Entries

Format:

```markdown
### CRASH-NNN — <symptom in plain words> (YYYY-MM-DD)
- **Symptom:** what the operator saw
- **Root cause:** the actual defect, with file:line
- **Fix:** what changed (commit or PR)
- **Siblings checked:** other places the same bug could exist
- **Prevention:** test added / rule added / guardrail
```
