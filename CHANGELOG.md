# Changelog

## [1.1.0] - 2026-07-05

### Changed

- `fast-worker` — now opens with a machine-readable `RESULT: DONE/PARTIAL/BLOCKED` line, pastes real verification output, labels unverified claims `[inferred]`/`[unverified]`, and states explicit default boundaries (no commit/push/PR unless ordered).
- `deep-reasoner` — now opens with `RECOMMENDATION: <one sentence> — confidence: HIGH/MEDIUM/LOW`, labels evidence tri-state, and makes its recommend-only / no-side-effects role explicit. Kept on all tools; a local `tools:` allowlist (e.g. `["Read","Grep","Glob","Bash","WebSearch","WebFetch"]`) is a documented opt-in, not the default, because static allowlists block per-machine MCP tools.
- Re-running the installer on a machine with v1.0.0 copies reports `[conflict]` for these two agents — diff and take the bundled version.

### Fixed

- `install.sh` — agent definitions now install globally into `$CLAUDE_CONFIG_DIR/agents` (default `~/.claude/agents`) instead of per-project (fix landed on `main` after v1.0.0; first released here).

## [1.0.0] - 2026-07-05

First release.

### Added
- **`fast-worker`** (Sonnet 5, `effort: max`) — execution agent for implementation, tests, refactoring, and documentation updates
- **`deep-reasoner`** (Opus 4.8, `effort: max`) — architecture research agent for proposals, complex multi-step reasoning, and high-risk analysis
- **`gatekeeper`** (Opus 4.8, `effort: max`) — acceptance and ship gate: reviews the diff against the goal, runs the project's real verification, and returns a `PASS`/`FAIL`/`BLOCKED` ship recommendation — ship actions only on an explicit orchestrator execution order (#1)
- **`scripts/install.sh`** — idempotent installer; never overwrites a differing file (reports `[conflict]`, exits `3`); installs the project agents, appends the `## Model Routing Hierarchy` section to the global `CLAUDE.md`, checks the codex plugin, and runs headless smoke tests
- **`assets/model-routing-hierarchy.md`** — source of the `## Model Routing Hierarchy` section the installer appends to the global `CLAUDE.md`
- **`SKILL.md`** — Claude Code skill manifest; the repo doubles as a skill when placed or symlinked under `~/.claude/skills/`
- Bilingual README (English / 简体中文) — usage showcase and a "send to your Claude" install path
