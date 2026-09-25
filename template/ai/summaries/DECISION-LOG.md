# Decision Log

Append-only. One entry per architectural or product decision. Newest at the bottom.

Format:

```markdown
### DEC-NNN — <title> (YYYY-MM-DD)
- **Status:** proposed | accepted | superseded by DEC-NNN
- **Context:** why a decision was needed
- **Decision:** what we chose
- **Alternatives:** what we rejected and why
- **Consequences:** what this makes easier or harder
```

---

### DEC-001 — Adopt agent-kit repo structure (<YYYY-MM-DD>)
- **Status:** accepted
- **Context:** Work happens across multiple AI tools and sessions; context was being lost between them.
- **Decision:** Use `AGENTS.md`, `ai/handoffs/CURRENT-STATE.md`, this log, the crash log, and GitHub Actions CI as the standard.
- **Alternatives:** Tool-specific memory or chat history only. Rejected: not portable, not reviewable.
- **Consequences:** Every session ends with a doc update; any agent can resume from the repo alone.
