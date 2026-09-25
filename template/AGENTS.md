# AGENTS.md

Instructions for any AI agent (Cursor, Claude Code, Codex, Perplexity) working in this repo. Keep this file under 100 lines. Details live in the linked docs.

## What this is

<One paragraph: what the app does, who it's for, current status (prototype / beta / live), live URL.>

## Stack

- **Frontend:** <e.g. React + Vite + Tailwind + shadcn/ui>
- **Backend:** <e.g. FastAPI (Python 3.12) / Express (Node 20)>
- **Data:** <e.g. Supabase Postgres, tables: ...>
- **Hosting:** Railway, services: <list>. See `ops/runbooks/RAILWAY.md`.

## Commands

Run these before every PR. CI runs the same ones.

```bash
<install>        # e.g. npm ci  |  pip install -r requirements.txt
<dev>            # e.g. npm run dev
<typecheck>      # e.g. npm run typecheck   (must cover server AND client)
<lint>           # e.g. npm run lint  |  ruff check .
<test>           # e.g. npm test  |  pytest
<build>          # e.g. npm run build
```

## Repo map

```
<dir>/     <what lives here>
docs/      architecture and design docs
ai/        handoffs, decision log, crash log, session summaries
ops/       runbooks (Railway)
```

## Every session

1. Start: read `ai/handoffs/CURRENT-STATE.md` and the Hard Rules in `ai/summaries/CRASH-AND-FIX-LOG.md`. Branch from `origin/main`.
2. Work: one focused change, with tests. Docs updated in the same PR when behavior changes.
3. Finish: PR against `main` with check output as evidence. Verify deploys on the live URL. Update CURRENT-STATE (use the `close-session` skill).

## Protected areas: ask before changing behavior

- `<path>`: <why, e.g. order execution / accounting / auth / migrations>
- Secrets: never commit. Variable names go in `.env.example` only.

## Known sharp edges

- <One line per recurring gotcha; the full history is in the crash log.>

## Docs

- Architecture: `docs/ARCHITECTURE.md`
- Current state: `ai/handoffs/CURRENT-STATE.md`
- Decisions: `ai/summaries/DECISION-LOG.md`
- Bugs and lessons: `ai/summaries/CRASH-AND-FIX-LOG.md`
- Deploy: `ops/runbooks/RAILWAY.md`
