---
name: setup-model-routing
description: Install the user's standard model-routing setup (Fable 5 orchestrator, deep-reasoner = Opus 4.8 max for architecture research, fast-worker = Sonnet 5 max for execution, gatekeeper = Opus 4.8 max for the acceptance and ship gate, Codex plugin as independent peer engineer) into the current project and machine. Use whenever the user mentions 模型分工, model routing, routing hierarchy, fast-worker, deep-reasoner, 双轨 / dual-track, peer engineer setup, or wants to replicate/set up these subagents and the global CLAUDE.md routing section in a new project, repo, or machine — even if they only say "set up my agents" or "同步模型配置".
---

# Setup Model Routing

Reproduce the user's standard three-layer model-routing setup. After a successful run, all of the following hold:

1. The target project has `.claude/agents/fast-worker.md`, `.claude/agents/deep-reasoner.md`, and `.claude/agents/gatekeeper.md` (from `assets/`).
2. The global `CLAUDE.md` (`$CLAUDE_CONFIG_DIR/CLAUDE.md`, default `~/.claude/CLAUDE.md`) contains the `## Model Routing Hierarchy` section.
3. The codex plugin (`codex@openai-codex`) is installed and its readiness check reports `"ready": true`.
4. All three agents answer a headless smoke test.

The routing model this installs: Fable 5 plans, delegates, and synthesizes — and exists only in the main loop; every spawned subagent (foreground or background, Agent tool or Workflow) MUST carry an explicit agent type or model override and never inherit Fable (quota constraint). deep-reasoner (Opus, `effort: max`) executes architecture research, hard reasoning, and judgment-type runs and returns recommendations — the final framework is always confirmed by the orchestrator; fast-worker (Sonnet, `effort: max`) executes implementation, tests, refactoring, docs, grading, and mechanical work; gatekeeper (Opus, effort: max) is the acceptance and ship gate that reviews delivered work against the goal, runs verification, and returns a PASS/FAIL/BLOCKED ship recommendation — the orchestrator decides, ship actions run only on its explicit execution order, and the gate never fixes code; Codex acts as an independent peer engineer. High-stakes decisions run dual-track: deep-reasoner and Codex produce solutions in parallel without seeing each other, then the main loop compares and decides.

## Workflow

Run the installer from the target project root (or pass `--project <dir>`):

```bash
bash ~/.claude/skills/setup-model-routing/scripts/install.sh
```

Flags: `--project <dir>` (default: cwd), `--skip-plugin` (no plugin install/check), `--skip-smoke` (no headless agent test — use in sandboxes without API credentials).

Then read the line-prefixed report and act on it:

- `[ok]` / `[new]` — nothing to do.
- `[conflict]` — a target agent file exists with different content. Never overwrite it: the user may have deliberately customized it. Show the user the diff (the report line contains the exact `diff` command) and ask whether to keep their version, take the bundled one, or merge.
- `[warn]` — a layer could not be verified (missing `claude`/`node`/`codex` CLI, codex not logged in, smoke test failed). Report the layer as unverified and give the fix: `npm install -g @openai/codex` for a missing CLI, `!codex login` for auth (interactive — the user must run it themselves), restart/`/reload-plugins` for a session that can't see new agent types yet.

The script exits 0 on success, 3 when any `[conflict]` was found, 2 on usage errors.

## Report format

Summarize per layer, separately — do not collapse into one "done": project agents / global CLAUDE.md / codex plugin / smoke tests. Unverified layers are explicit gaps, not successes. Remind the user that an already-running interactive session loads agent types at startup, so this session won't see newly installed agents until restart or `/reload-plugins`.

## Boundaries

- Do not edit `~/.claude/rules/ultracode.md` — it carries related routing rules but is managed by the user directly.
- Do not enable the codex stop-time review gate; the user positions Codex as a peer engineer, not a mandatory reviewer.
- Do not "fix" a `[conflict]` by overwriting; that path always goes through the user.
