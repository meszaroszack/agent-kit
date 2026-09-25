---
name: bootstrap-repo
description: Install Zack's standard agent-kit structure into a new or existing repo — AGENTS.md, CURRENT-STATE handoff, decision and crash logs, architecture doc, Railway runbook, project rules, PR template, and GitHub Actions CI — filled in from the actual codebase. Use when the user types /bootstrap-repo, starts a new project, or a repo has no AGENTS.md.
disable-model-invocation: true
---

# Bootstrap Repo

Templates live in the `template/` folder next to this file. Copy them, then **fill them in from the real code**. Leaving placeholders defeats the purpose.

## Steps

1. **Survey the repo** before writing anything: languages, frameworks, package managers, entry points, how it runs locally, Railway configs, env vars, existing docs and tests, recent `git log`. For an existing repo, hand off to the **architect** subagent for a short architecture summary.

2. **Branch:** `git checkout -b chore/agent-kit-bootstrap origin/main` (skip for a brand-new repo with no commits).

3. **Copy templates without overwriting.** If a file already exists (e.g. `README.md`, an existing `AGENTS.md` or crash log), merge the kit's structure into it and keep existing content.
   ```
   AGENTS.md
   CLAUDE.md
   docs/ARCHITECTURE.md
   ai/handoffs/CURRENT-STATE.md
   ai/summaries/DECISION-LOG.md
   ai/summaries/CRASH-AND-FIX-LOG.md
   ai/summaries/_TEMPLATE.md
   ops/runbooks/RAILWAY.md
   .cursor/rules/project-guardrails.mdc
   .github/pull_request_template.md
   .github/workflows/ci.yml
   .env.example            (only if missing; names only, never values)
   ```

4. **Fill in, from the code:**
   - `AGENTS.md`: project summary, stack, exact local run/test/typecheck/lint/build commands, repo map, protected areas, links.
   - `docs/ARCHITECTURE.md`: components, data flow, where state lives, external services.
   - `ops/runbooks/RAILWAY.md`: each Railway service, its root directory, config file, start command, health path, env var names, volumes, databases.
   - `.cursor/rules/project-guardrails.mdc`: set `globs` to the risky paths (auth, money, persistence) and write the rules for them.
   - `ci.yml`: remove the Node or Python job if unused; set the working directory for monorepos.
   - `CURRENT-STATE.md`: an honest snapshot. What works, what's untested, known problems.
   - Seed `DECISION-LOG.md` with DEC-001 "Adopt agent-kit structure" and any decisions visible in the code or README.

5. **Flag problems you found** in CURRENT-STATE open items: duplicate deploy configs, missing tests, missing typecheck coverage, secrets in code, doc contradictions.

6. **Make CI real:** run the CI commands locally. If the repo lacks `typecheck`, `lint` or `test` scripts, add minimal working ones (hand off to the **test-engineer**). CI should be green on the bootstrap PR.

7. **Open the PR** (`gh pr create`), then tell Zack how to turn on branch protection: GitHub repo → Settings → Branches → add a rule for `main` → require a pull request, and require the `CI` status checks to pass.

## Done when

- [ ] No `<placeholder>` text left in any copied file
- [ ] CI passes on the PR
- [ ] CURRENT-STATE reflects reality, including problems
