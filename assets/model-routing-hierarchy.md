## Model Routing Hierarchy

User-specified model division of labor — applies across all projects and all sessions.

- **Fable 5 (main loop) = orchestrator, exists only in the main loop.** Responsible only for: plan first → then delegate → finally synthesize. The overall framework and final decisions are confirmed by Fable; it never does execution work itself.
- **Subagents must always override the model — never inherit Fable (MANDATORY, quota constraint).** Every spawn — Agent tool or Workflow `agent()`, foreground or background, ultracode or not — must explicitly specify an agent type or model. Omitting the model lets the subagent inherit the main loop's Fable and burn through quota fast; this is forbidden. This matters most for long-running background agents such as eval runs, background research, and codebase audits.
- **Research/judgment work → `deep-reasoner` (Opus 4.8 + effort max).** Architecture proposals, research, trade-off analysis, high-risk analysis, codebase judgment calls, judgment-type runs within evals. When passed raw in a Workflow script, use `model: 'opus', effort: 'max'`.
- **Execution work → `fast-worker` (Sonnet 5 + effort max).** Implementation, testing, refactoring, documentation, grading/assertion checks, mechanical execution. When passed raw in a Workflow script, use `model: 'sonnet'`.
- **Codex = independent peer engineer.** Not just a reviewer — specifically tasked with finding faults and offering a second solution. Invoked via the codex plugin's `/codex:*` commands or `codex exec`.
- For Agent tool spawns, prefer agent type (`deep-reasoner` / `fast-worker`) — their definitions already pin down model+effort. When passing a raw model in a Workflow script, always pass effort alongside it.

### High-stakes decisions

High-stakes decisions run dual-track: for the same question, Opus produces one solution and Codex produces another in parallel, each independent and blind to the other's result. Fable 5 compares where the two diverge and the reasoning behind each, then makes the final call — a synthesis, not a simple either/or pick.
