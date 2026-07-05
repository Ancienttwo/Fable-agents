# Changelog

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
