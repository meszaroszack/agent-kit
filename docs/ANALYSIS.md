# Analysis: How Zack Builds Today

Reviewed September 2026 from three public repos:

- [`zerotrading`](https://github.com/meszaroszack/zerotrading): governance and docs parent for live Kalshi trading bots
- [`apollo-agent`](https://github.com/meszaroszack/apollo-agent): Kalshi NCAAB trading system (FastAPI + Next.js)
- [`the_rest_is_history_sorting`](https://github.com/meszaroszack/the_rest_is_history_sorting): podcast tagging pipeline + React "Atlas" web app

This document is the reasoning behind every design choice in `agent-kit`.

---

## 1. The short version

You are not vibe coding anymore. `zerotrading` already has a better agent-governance system than most professional teams: hard rules, handoffs, a decision log, a crash log with 30+ entries, guardrail docs, and a session output contract.

The problems are not missing ideas. They are:

1. **Too many overlapping instruction files.** They disagree with each other and cost a lot of context to load.
2. **Rules enforced by prose, not by machines.** "Run typecheck", "branch from main" and "verify on Railway" are written down, but nothing enforces them, so they get skipped. Your crash log proves it.
3. **Governance lives in a different repo from the code.** Agents working in `zerotrading-core` have to fetch rules from `zerotrading`, and often don't.
4. **Maturity is uneven.** One repo has the full system; the other two have great READMEs but nothing for the next agent: no handoff, no tests, no decision history.

`agent-kit` keeps your system and fixes those four things.

---

## 2. Your stack (the standard the kit assumes)

| Layer | What you use |
|---|---|
| Hosting | Railway (Nixpacks or Dockerfile, `railway.json`) |
| Source control | GitHub, PR-per-change intent |
| Data | Supabase or Railway Postgres |
| Web frontends | React + Vite + Tailwind + shadcn/ui (Express static server), or Next.js + Tailwind |
| Backends | TypeScript (Node/Express) or Python (FastAPI, asyncio) |
| AI tools | Perplexity Computer (primary, historically), Cursor, Claude Code |
| Domain | Kalshi prediction markets (RSA-PSS auth, WebSocket orderbooks), data pipelines with LLM tagging |

---

## 3. What is working (keep it)

- **Excellent READMEs.** Architecture diagrams, risk-control tables, API references, reproduction steps. Apollo's and the Atlas app's READMEs are better than most commercial repos.
- **Safety-first product thinking.** paper → safe-live → live, quarter-Kelly caps, reconciliation halts, "fail closed on ambiguity", protected core (state machine, ledger, reconciliation).
- **The crash log.** `CRASH-AND-FIX-LOG.md` is your most valuable file. Every entry has a root cause and a fix, and there's a failure-pattern index. This is institutional memory, and the kit makes it standard everywhere.
- **The operator-expertise rules.** "Don't blame the operator's config before reading the code" and "Pushed is not fixed" are exactly right. They go into the global rules for every project.
- **Handoffs.** `CURRENT-STATE.md` as an overwritten pointer file, plus append-only logs, is the right structure.

---

## 4. What is breaking (and the fix)

### 4.1 Instruction sprawl: six files tell the agent what to read first, and they disagree

| File | "Read first" list |
|---|---|
| `README.md` | 5 files |
| `AGENTS.md` | 5 different files, including a `git` command sequence |
| `ai/prompts/MASTER-PROMPT.md` | 12 files, including one in a *different repo* |
| `ai/handoffs/CURRENT-STATE.md` | 8 files |
| `ai/checklists/SESSION-OUTPUT-CONTRACT.md` | 7 items |
| `ai/system/README-AI-SYSTEM.md` | 4 files |

End-of-session requirements also differ. The README says "DECISION-LOG + fresh-session summary". AGENTS.md says "four governance files". MASTER-PROMPT lists six steps.

Why it matters: an agent that reads all of it burns a big chunk of its context before writing a line of code. An agent that skims picks one list at random. Either way, rules get dropped.

**Fix in the kit:**
- **One short `AGENTS.md`** per repo, under 100 lines. It's the only file every tool (Cursor, Claude Code, Codex) reads automatically.
- **`CURRENT-STATE.md`** is the only other file read every session.
- **Domain guardrails** (Kalshi auth, persistence, market data) become scoped rules that load automatically only when matching files are touched.
- **Process** (kickoff, close-out, deploy) lives in skills that run when invoked, not in prose that's paid for every session.
- **No copy-paste master prompt.** Cursor loads rules for you.

### 4.2 Rules written but not enforced

Evidence from your own logs:

- **FIX-CORE-009:** blank production dashboard (`posBadgeColor is not defined`). Root cause: `npm run typecheck` only checked the server; the client was never typechecked. It's still an open item in CURRENT-STATE.
- **CORE-STABILIZATION-V1-RECONCILE:** an agent worked off a stale branch. The rule "branch from origin/main" existed and was ignored.
- **Branch protection** is still "OPERATOR ACTION REQUIRED" in CURRENT-STATE.
- **No tests** exist in `apollo-agent` or `the_rest_is_history_sorting`, despite Apollo handling real money.

**Fix in the kit:**
- A **GitHub Actions CI workflow** (`template/.github/workflows/ci.yml`) runs typecheck, lint, tests and build on every PR, for Node and Python. A machine checks it, so no agent can skip it.
- **Branch protection** on `main` requires CI to pass. The `bootstrap-repo` skill walks you through it.
- A **test-engineer** subagent whose job is to add the missing tests and smoke tests.
- A **reviewer** subagent that checks each change against the repo's crash log before a PR is opened.

### 4.3 The same bug keeps coming back in a new file

| Pattern | Crash entries |
|---|---|
| Kalshi RSA signing: wrong padding (PKCS1v15 instead of PSS) | CRASH-009 in REST client, then CRASH-017 in WebSocket client |
| Kalshi signing: wrong message string or base URL | CRASH-010, CRASH-011, CRASH-018 |
| Railway: healthcheck fails because the HTTP server starts too late | CRASH-013 |
| Railway: state lost on redeploy (ephemeral disk) | CRASH-032 (trade history wiped, $12.23 invisible) |
| Railway: US data centers geo-blocked by Binance (HTTP 451) | CRASH-023, CRASH-026 |
| Dashboard HTML embedded in Python strings breaks JS | CRASH-031 |
| Wrong field names or enums from Kalshi API | CRASH-019, CRASH-020, CRASH-021 |

Why it matters: fixing a bug in one file doesn't protect the next file an agent writes. Apollo has its own separate `signer.py` implementing the same Kalshi signing, so the same class of bug can appear a third time.

**Fix in the kit:**
- Crash logs get a **"Hard Rules"** section: one line per lesson. The reviewer and debugger subagents must check changes against it.
- **Recommendation (not built yet):** extract Kalshi auth, client and WebSocket code into one shared, tested package used by every bot. Write it once, test it against a known-good signature, and stop re-implementing it per repo.
- The **Railway runbook template** ships with the known failure modes pre-filled: healthcheck timing, volumes vs ephemeral disk, egress geo-blocks, `$PORT`.

### 4.4 Governance split across repos

`zerotrading` holds the rules; `zerotrading-core` holds the live code. MASTER-PROMPT also references `ops/runbooks/RAILWAY-KNOWN-ISSUES.md` "in the beta repo". An agent opened in a code repo sees none of this unless it goes and fetches it.

**Fix in the kit:** every deployed repo carries its own `AGENTS.md`, `CURRENT-STATE.md`, logs and runbook. Cross-cutting rules that apply everywhere (your working style) live in the **global** layer, installed once on your machine. A parent or docs repo is still fine for research and strategy, but an agent should never need it to work safely.

### 4.5 Contradictions inside the docs

- MASTER-PROMPT says: "ALL state MUST be persisted in Supabase (NEVER in-memory or file-based)."
- CURRENT-STATE documents the live Core bot storing state on a Railway volume at `STATE_DIR=/data`, including `bid-series.json`.

One of these is out of date. An agent that believes the first one might "fix" the volume-backed storage and break production. The kit's session-closer checks for contradictions like this when it updates docs.

### 4.6 Deploy config ambiguity

- `apollo-agent` has `railway.json` **and** `railway.toml` at the root **and** in `frontend/`, plus `backend/railway.json`, `nixpacks.toml` and `Dockerfile`.
- `the_rest_is_history_sorting` has root `railway.json`, `nixpacks.toml`, `Procfile` and a proxy `package.json`, **plus** `app/railway.json`.

When several configs exist, which one Railway uses depends on service settings in the dashboard that aren't visible in the repo. That's a classic "works on one deploy, breaks on the next" source. **Fix:** exactly one config-as-code file per Railway service, and the runbook records which service uses which root directory.

### 4.7 One-shot builds leave no trail

`the_rest_is_history_sorting` is a polished one-shot build, but:

- The README says "Live preview: attached in the conversation". That artifact lives in a Perplexity chat, not the repo.
- The pipeline depends on `pplx_sdk`, which only exists inside Perplexity Computer.
- Episode data is duplicated in `data/` and `app/client/public/`, so the two copies can drift.
- It has a `drizzle.config.ts` although the README says there's no database. That's leftover scaffold.
- It has no tests, no handoff and no decision history. The next agent starts from zero.

Apollo is the same: a strong architecture doc, but no record of why decisions were made, no tests, and no state file.

**Fix:** the `bootstrap-repo` skill retrofits any repo with the standard docs, CI and handoff. Every future session ends with `close-session`, so nothing important lives only in a chat.

### 4.8 Worth a dedicated look (not concluded here)

- **Apollo's onboarding UI accepts a Kalshi private key** pasted or uploaded in the browser. How that key is transmitted, stored and scoped deserves a security review before anyone other than you uses it.
- **Sparse commit history.** Apollo and the Atlas app look like a few large commits. Smaller PRs make the reviewer and CI far more useful.

---

## 5. Your working style (what the kit must fit)

From your repos and how you described working:

- **You want to walk in and chat.** No ceremony, no pasting a master prompt. The system should route work to the right specialist on its own. → The main chat acts as orchestrator; subagents are chosen by description.
- **You're the operator and domain expert; agents are staff.** → Global rule: diagnose from code first, never blame config, verify before claiming done.
- **You want real documentation and real architecture.** → Architect agent and Plan mode before big changes; docs are updated in the same PR as code.
- **Railway + GitHub is home.** → The deploy agent knows Railway; CI runs on GitHub; PRs are the unit of work.
- **You move between tools** (Perplexity, Cursor, Claude Code). → Everything that matters lives in plain markdown in the repo (`AGENTS.md`, plus `CLAUDE.md` pointing to it), not in any one tool's memory.

---

## 6. The target workflow

```
You chat in Cursor
   │
   ├─ big or unclear?  → Architect subagent (or Plan mode) → plan + ADR in docs → you approve
   │
   ├─ something broken? → Debugger subagent → root cause from code/logs → fix → crash log entry
   │
   ├─ building          → main agent works on a branch off origin/main
   │                         → Test engineer adds or updates tests
   │                         → Reviewer checks diff vs guardrails + crash log
   │                         → PR opened; CI must pass
   │
   ├─ shipping          → Railway deployer → deploy → hit /health → read logs → confirm
   │
   └─ wrapping up       → Session closer → CURRENT-STATE, DECISION-LOG, CRASH log, handoff
```
