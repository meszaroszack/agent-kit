# agent-kit

Zack's operating system for building web apps with AI agents: documented, tested, deployed on Railway, and resumable by any agent from the repo alone.

- **You chat.** The main Cursor agent routes work to six specialists: architect, debugger, reviewer, test engineer, Railway deployer and session closer.
- **Every repo carries its own memory:** `AGENTS.md`, a current-state handoff, a decision log, a crash log and a Railway runbook.
- **Machines enforce the rules** (CI on every PR, branch protection), not paragraphs agents skim.
- **Works across tools:** Cursor, Claude Code and Perplexity all read the same markdown.

Why it's designed this way: [`docs/ANALYSIS.md`](docs/ANALYSIS.md), a review of `zerotrading`, `apollo-agent` and `the_rest_is_history_sorting`, and what to keep vs fix.

---

## Cursor in 2 minutes (for this kit)

| Cursor concept | What it is | Where it lives | In this kit |
|---|---|---|---|
| **User Rules** | Instructions added to *every* chat, in every project | Cursor Settings → Rules | `global/USER-RULES.md` (your working style) |
| **Project rules** | Instructions for one repo; can load only when certain files are touched | `<repo>/.cursor/rules/*.mdc` | `template/.cursor/rules/project-guardrails.mdc` |
| **AGENTS.md** | Plain-markdown project brief read automatically by Cursor, Claude Code, Codex | `<repo>/AGENTS.md` | `template/AGENTS.md` |
| **Subagents** | Specialists with their own instructions and a separate context. The main agent delegates to them based on their description | `~/.cursor/agents/*.md` (all projects) or `<repo>/.cursor/agents/` | `global/agents/` (6 agents) |
| **Skills** | Saved playbooks you run by typing `/name` in chat | `~/.cursor/skills/<name>/SKILL.md` | `global/skills/` (4 skills) |
| **Modes** | **Agent** = does the work. **Plan** = writes a plan for approval first. **Ask** = answers only, no edits | Mode picker under the chat box | Use Plan for new features and architecture |

The "global" folders (`~/.cursor/...`) mean the agents and skills follow you into **every** project on this computer. The per-repo files travel with the code on GitHub.

---

## Install (one time per computer)

1. **Get the kit** (after it's on GitHub):
   ```powershell
   cd C:\Users\User\Projects
   git clone https://github.com/meszaroszack/agent-kit.git
   ```
2. **Install agents and skills:**
   ```powershell
   cd agent-kit
   powershell -ExecutionPolicy Bypass -File scripts/install.ps1          # Cursor
   powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -Claude  # Cursor + Claude Code
   ```
3. **Add your User Rules:** ask the agent to "add my agent-kit user rules" (it can save them for you), or copy everything below the line in `global/USER-RULES.md` into **Cursor Settings (`Ctrl+Shift+J`) → Rules**.
4. **Restart Cursor.**

Updating the kit later: edit files here, commit, then re-run `install.ps1`. Every project picks up the change.

---

## Daily workflow

Open a project folder in Cursor (**File → Open Folder**), open the chat (`Ctrl+L`), and talk normally. Examples:

| You type | What happens |
|---|---|
| `/kickoff` | Checks git, reads CURRENT-STATE and the last summary, pings production health, proposes today's objective |
| "I want to add user accounts with Supabase auth" | Main agent hands it to the **architect**, which returns a plan and decision entries for your approval |
| "The dashboard is blank in prod" | **Debugger**: reads the crash log and code, finds the root cause, fixes it, adds a regression test and a crash entry |
| "Build it" (after approving a plan) | Main agent builds on a branch; **test-engineer** adds tests |
| `/ship` | Rebase, checks, **reviewer**, PR, CI, merge (with your OK), **railway-deployer** verifies live, docs updated |
| "Is it live?" | **Railway deployer** checks the health endpoint and logs |
| `/close-session` | **Session closer** updates CURRENT-STATE, logs and a dated handoff, and gives you the first message for next time |

You can always direct traffic yourself: *"have the reviewer look at this"*, *"use the architect first"*.

### The flow

```
chat → (architect / Plan mode) → branch → build + tests → reviewer → PR + CI → merge → deploy + verify → close-session
```

---

## Bringing a repo up to standard

In any repo, new or existing, type `/bootstrap-repo`. It:

1. Surveys the actual code (stack, commands, Railway services, env vars).
2. Adds `AGENTS.md`, `CLAUDE.md`, `docs/ARCHITECTURE.md`, `ai/handoffs/CURRENT-STATE.md`, the decision and crash logs, the session template, `ops/runbooks/RAILWAY.md`, a guardrails rule, a PR template and GitHub Actions CI.
3. Fills them in from the code, with no placeholders left, and lists problems it found.
4. Makes CI pass and opens a PR.

Then turn on **branch protection**: GitHub repo → Settings → Branches → rule for `main` → require a pull request, and require the `CI` checks to pass.

Suggested order for your repos:

| Repo | Why | Notes |
|---|---|---|
| `apollo-agent` | Handles real money, has no tests or handoff | Consolidate duplicate Railway configs; security review of private-key onboarding |
| `the_rest_is_history_sorting` | Quick win, good practice run | Remove `pplx_sdk` lock-in and the unused Drizzle config; one copy of the data |
| `zerotrading` family | Already has the system; needs slimming, not adding | Merge the six "read first" lists into one `AGENTS.md`; fix the Supabase-only vs `STATE_DIR` volume contradiction; wire the client typecheck |

---

## What's in the kit

```
agent-kit/
├── README.md                     you are here
├── docs/ANALYSIS.md              review of current repos and workflow → design rationale
├── global/                       installed once per computer
│   ├── USER-RULES.md             paste into Cursor Settings → Rules
│   ├── agents/                   architect, debugger, reviewer, test-engineer,
│   │                             railway-deployer, session-closer
│   └── skills/                   kickoff, ship, close-session, bootstrap-repo
├── template/                     copied into each repo by /bootstrap-repo
│   ├── AGENTS.md  CLAUDE.md  .env.example
│   ├── docs/ARCHITECTURE.md
│   ├── ai/handoffs/CURRENT-STATE.md
│   ├── ai/summaries/{DECISION-LOG, CRASH-AND-FIX-LOG, _TEMPLATE}.md
│   ├── ops/runbooks/RAILWAY.md
│   ├── .cursor/rules/project-guardrails.mdc
│   └── .github/{pull_request_template.md, workflows/ci.yml}
└── scripts/install.ps1           installs global/ into ~/.cursor (and ~/.claude)
```

---

## Roadmap

- [ ] Hooks: automatic reminder to run `/close-session`, block commits containing secrets
- [ ] Shared `kalshi-client` package (auth, REST, WebSocket) with golden-signature tests, used by every bot
- [ ] `/new-app` skill: scaffold a Railway-ready React + API project with CI from day one
- [ ] Bugbot or cloud-agent PR review on GitHub
