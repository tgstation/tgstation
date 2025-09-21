# Implementation Plan: AI-Controlled Human Crew Foundation

**Branch**: `001-DRMCTS` | **Date**: 2025-09-21 | **Spec**: `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/spec.md`
**Input**: Feature specification from `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Deliver an AI control foundation for unattended human crew that uses doubly robust MCTS with per-action taxonomy exploration scaling, produces administrator telemetry, and guarantees clean player handoff and emergency responsiveness.

## Technical Context
**Language/Version**: Dream Maker (BYOND 515.x) for simulation logic; TypeScript/React (tgui) for administrator UI overlays.  
**Primary Dependencies**: Existing tgstation subsystems (`SSai_controller` to be introduced), `/datum/job` data, `SSdbcore` for telemetry persistence, Admin Config TGUI pipeline.  
**Storage**: `SSdbcore` SQL tables for 24h telemetry aggregates; `/config/ai_foundation.json` + config entries for persistence.  
**Testing**: Dream Maker `datum/unit_test` harness (contract tests authored) plus manual quickstart scenarios for behavior that lacks automation.  
**Target Platform**: Linux-hosted BYOND server with tgui frontend served through Node build pipeline.  
**Project Type**: single (Dream Maker project with supporting JS UI).  
**Performance Goals**: Maintain ≤50 ms compute per evaluation cycle, sustain 1.5 s cadence staggered across AI agents, and keep tick-rate impact <5% CPU over baseline.  
**Constraints**: Exploration scaling clamps (`c_pi` within 0.5–2.5), telemetry buffer bounded to 30 minutes per agent, subsystem must suspend instantly when players reclaim control.  
**Scale/Scope**: Designed for 20–30 simultaneous AI crew during low-population shifts; telemetry interface must handle dozens of entries without UI degradation.  
**Arguments Incorporated**: Action taxonomy categories (Routine Upkeep, Maintenance & Logistics, Medical Response, Security & Emergency, Social & Support) each map to configurable exploration multipliers derived from `c_pi` baseline guidance.

## Constitution Check
- **Tests Gate Features**: Created failing Dream Maker contract tests at `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/contracts/tests/admin_blackboard_test.dm` covering list, detail, and policy update endpoints; manual quickstart scenarios in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/quickstart.md` guard critical workflows.
- **Round Stability Over Novelty**: Evaluation budget documented in Technical Context; expect <50 ms per cycle. Rollback lever: toggle `ai_control_enabled` config entry to disable subsystem + revert plan via config hot reload, plus maintain branch-specific revert instructions.
- **Dream Maker Modularity**: All new behavior encapsulated in datums (`/datum/ai_crew_profile`, `/datum/ai_control_policy`, etc.) outlined in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/data-model.md`; shared utilities stay under `/code/modules/ai_control/` with minimal overrides.
- **Exploit Surface Control**: Research captured guardrails for griefing, reservation priority, and rate limits (see `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/research.md`); contracts enforce sanitized admin endpoints.
- **Transparent Collaboration**: Spec linked above, plan stored in repo, quickstart + contracts + data model generated, and agent context will be updated via `.specify/scripts/bash/update-agent-context.sh codex` to broadcast tech changes.

## Project Structure

### Documentation (this feature)
```
specs/001-DRMCTS/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── admin_blackboard.yaml
│   └── tests/
│       └── admin_blackboard_test.dm
└── tasks.md             # Generated during /tasks
```

### Source Code (repository root)
```
src/
├── (existing tgstation DM tree under /code)
└── (new module path: /code/modules/ai_control)

tests/
├── unit/ (Dream Maker unit tests including new contract tests)
└── integration/
```

**Structure Decision**: Option 1 (single project) — Dream Maker backend plus supporting tgui pane within existing monorepo.

## Phase 0: Outline & Research
- Extracted clarifications for conflict resolution, authoritative role objectives, telemetry retention, configuration interface expectations, emergency overrides, and exploit mitigation.
- Consolidated outcomes in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/research.md` with decisions, rationale, and rejected alternatives.
- Result: All `NEEDS CLARIFICATION` items now resolved with documented assumptions and guardrails; proceeding to design.

## Phase 1: Design & Contracts
- Modeled runtime datums, relationships, and state transitions in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/data-model.md`.
- Authored admin API contract at `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/contracts/admin_blackboard.yaml` plus failing DM contract tests in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/contracts/tests/admin_blackboard_test.dm`.
- Captured manual validation steps in `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/quickstart.md`, including emergency reprioritization and configuration adjustments.
- Ran `.specify/scripts/bash/update-agent-context.sh codex` to refresh shared agent context with the new tech stack details.

**Post-Design Constitution Check**: Re-reviewed guardrails after Phase 1 artifacts; no additional violations or waivers required.

## Phase 2: Task Planning Approach
- Use `/mnt/z/Backup/SS13/gurtstation/.specify/templates/tasks-template.md` as base.
- Generate tasks covering:
  - Contract test execution for each admin endpoint.
  - Implementation of new datums and subsystem scaffolding before hooking into mobs.
  - Integration tasks for admin TGUI blackboard and config UI.
  - Manual quickstart checklist validation after automated tests.
- Order tasks by TDD: create/enable failing tests, implement AI core, integrate telemetry, finalize UI. Mark data isolation tasks ([P]) when files/modules do not overlap.
- Expect 25–30 numbered tasks mixing DM, tgui, and config updates.

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| _None_ | — | — |

## Progress Tracking
- [x] Feature spec loaded and technical context resolved
- [x] Initial Constitution Check complete (no blockers)
- [x] Phase 0 research completed (`research.md`)
- [x] Phase 1 design artifacts generated (data model, contracts, tests, quickstart)
- [x] Agent context script executed after final plan save
- [x] Post-design Constitution Check confirmed
- [x] Ready for /tasks export
