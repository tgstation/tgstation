# Tasks: AI-Controlled Human Crew Foundation

**Input**: Design documents from `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/`  
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/, quickstart.md  
**Arguments**: (none provided)

## Phase 3.1: Setup
- [X] T001 Scaffold AI control module entry points by adding `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/_ai_control.dm` and registering it in `/mnt/z/Backup/SS13/gurtstation/tgstation.dme` so Dream Maker compiles the new feature bundle.
- [X] T002 [P] Create `/mnt/z/Backup/SS13/gurtstation/SQL/ai_decision_log.sql` with the `ai_decision_log` table and retention cron stub to support telemetry persistence.
- [X] T003 [P] Seed `/mnt/z/Backup/SS13/gurtstation/config/ai_foundation.json` plus example overrides under `/mnt/z/Backup/SS13/gurtstation/config/example/` to expose default exploration multipliers and safety thresholds.

## Phase 3.2: Tests First (TDD)
- [X] T004 [P] Promote the admin blackboard contract tests into `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_blackboard_contract.dm`, ensuring they fail until endpoints exist.
- [X] T005 [P] Add janitor workflow integration test covering Acceptance Scenario #2 in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_janitor_flow.dm`.
- [X] T006 [P] Add player takeover handoff integration test for Acceptance Scenario #3 in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_takeover.dm`.
- [X] T007 [P] Add emergency reprioritization integration test for Acceptance Scenario #1 in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_emergency.dm`.
- [X] T008 [P] Add equipment contention edge-case integration test in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_reservations.dm` validating priority queue rules.

## Phase 3.3: Core Implementation
- [X] T009 [P] Implement `/datum/ai_control_policy` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/control_policy.dm`, loading defaults from config and exposing alert-level overrides.
- [X] T010 [P] Implement `/datum/ai_duty_objective` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/duty_objective.dm`, sourcing authoritative goal data from `/datum/job`.
- [X] T011 [P] Implement `/datum/ai_context_snapshot` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/context_snapshot.dm` with expiry and data-gathering helpers.
- [X] T012 [P] Implement `/datum/ai_decision_telemetry` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/telemetry_record.dm` including exploration bonus clamping and buffer linkage.
- [X] T013 [P] Implement `/datum/ai_equipment_reservation` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/equipment_reservation.dm` supporting priority scoring and expirations.
- [ ] T014 [P] Implement `/datum/ai_crew_profile` in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/crew_profile.dm`, wiring taxonomy weights, risk tolerance, rate limiting, and takeover safeguards.
- [ ] T015 Implement `SUBSYSTEM_DEF(ai_control_foundation)` in `/mnt/z/Backup/SS13/gurtstation/code/controllers/subsystem/ai_control_foundation.dm`, registering it in `/mnt/z/Backup/SS13/gurtstation/code/controllers/subsystem.dm` and wiring config toggles, cadence (1.5 s average), and stat instrumentation.
- [ ] T016 Integrate the subsystem with human lifecycle hooks in `/mnt/z/Backup/SS13/gurtstation/code/modules/mob/living/carbon/human/ai_control.dm`, covering eligibility checks and immediate player handoff.
- [ ] T017 Implement the doubly robust MCTS planner with action taxonomy scaling in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/planner.dm`, including the exploration term `a* = argmax_a(Q + c_pi * b * N / (1 + N_edge))`.
- [ ] T018 Implement the shared equipment reservation manager in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/reservation_manager.dm`, integrating conflict resolution with the planner and subsystem.
- [ ] T019 Implement the in-memory telemetry buffer and admin broadcast stream in `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/telemetry_manager.dm`, enforcing the 30-minute rolling window.
- [ ] T020 Extend telemetry persistence by finalizing `/mnt/z/Backup/SS13/gurtstation/SQL/ai_decision_log.sql` migrations and hooking `/mnt/z/Backup/SS13/gurtstation/code/modules/ai_control/telemetry_manager.dm` into `SSdbcore` with 24-hour aggregation jobs.
- [ ] T021 Wire admin configuration entries in `/mnt/z/Backup/SS13/gurtstation/code/controllers/configuration/entries/ai_foundation.dm` and ensure reload callbacks update active control policies.
- [ ] T022 Implement GET `/admin/ai/blackboard` in `/mnt/z/Backup/SS13/gurtstation/code/modules/admin/ai_blackboard.dm`, returning summaries that satisfy the contract schema.
- [ ] T023 Implement GET `/admin/ai/crew/{profile_id}` in `/mnt/z/Backup/SS13/gurtstation/code/modules/admin/ai_blackboard.dm`, streaming telemetry timelines with pagination.
- [ ] T024 Implement PATCH `/admin/ai/config` in `/mnt/z/Backup/SS13/gurtstation/code/modules/admin/ai_blackboard.dm`, validating payloads, refreshing policies, and logging overrides.
- [ ] T025 Build the TGUI AI blackboard interface in `/mnt/z/Backup/SS13/gurtstation/tgui/packages/tgui/interfaces/AIFoundationBlackboard.tsx` plus a supporting data store under `/mnt/z/Backup/SS13/gurtstation/tgui/packages/tgui/stores/ai_foundation.ts`.
- [ ] T026 Update the Admin Config TGUI in `/mnt/z/Backup/SS13/gurtstation/tgui/packages/tgui/interfaces/AdminConfig.tsx` (or existing config panels) to expose exploration multipliers, safety sliders, and presets tied to the new config entry.

## Phase 3.4: Integration & Stability
- [ ] T027 [P] Add unit coverage for control policy scaling/reset behavior in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_policy_unit.dm`.
- [ ] T028 [P] Add unit coverage for reservation prioritization and expiry handling in `/mnt/z/Backup/SS13/gurtstation/code/modules/unit_tests/ai_control_reservation_unit.dm`.
- [ ] T029 Execute Dream Maker unit tests (including new suites) via `DreamDaemon` harness from `/mnt/z/Backup/SS13/gurtstation/BUILD.cmd`, capturing logs for review.
- [ ] T030 Run manual verification steps from `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/quickstart.md`, annotating outcomes and filing issues for any failures.
- [ ] T031 [P] Create `/mnt/z/Backup/SS13/gurtstation/specs/001-DRMCTS/admin-playbook.md` summarizing GM monitoring workflows, rollback lever usage, and telemetry interpretation.
- [ ] T032 Add changelog entry under `/mnt/z/Backup/SS13/gurtstation/html/changelogs/archive/2025-09-21-ai-control.yml` documenting the feature, tests, and admin impact.

## Dependencies
- T001 precedes all implementation work; config (T003) depends on scaffolding.
- Test tasks T004–T008 must land before corresponding implementation tasks T009–T026.
- Data model tasks (T009–T013) unblock crew profile (T014) and subsystem/planner tasks (T015–T018).
- Telemetry tasks (T019–T020) depend on policy/profile/subsystem completion (T014–T018) and SQL scaffold (T002).
- Admin configuration task T021 depends on T003 and informs endpoints T024 & UI tasks T025–T026.
- Blackboard endpoints (T022–T024) must precede UI tasks T025–T026.
- Unit coverage (T027–T028) waits on corresponding implementations; T029–T032 close out verification and documentation.

## Parallel Execution Example
```
# After setup, launch contract/integration tests together:
task run T004
task run T005
task run T006
task run T007
task run T008

# Later, batch independent datum implementations:
task run T009
task run T010
task run T011
task run T012
task run T013

# Final polish parallel batch:
task run T027
task run T028
task run T031
```

## Notes
- [P] tasks touch disjoint files and may be executed concurrently once dependencies resolve.
- Always confirm new tests fail before implementing the corresponding feature (per constitution).
- Use the config toggle introduced in T021 as the rollback lever documented in the plan.
- Keep telemetry within the 30-minute in-memory window and 24-hour DB retention per requirements.
