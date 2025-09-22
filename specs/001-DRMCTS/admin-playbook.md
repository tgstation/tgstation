# Admin Playbook: AI-Controlled Human Crew Foundation

## Overview
This playbook summarizes how game masters and server administrators monitor, tune, and roll back the DR-MCTS AI crew subsystem shipped on branch `001-DRMCTS`. It assumes the feature flag entry `ai_control_enabled` is available and the new TGUI panels are compiled.

## Monitoring in Live Rounds
- Open the **AI Foundation Blackboard** verb (`Admin → Debug → AI Foundation Blackboard`) to review active profiles, current objectives, and planner health.
- The crew table highlights:
  - Profile status (`ACTIVE`, `PLAYER_OVERRIDE`, `LOCKDOWN`).
  - Current macro-option objective surfaced by the controller blackboard.
  - Recent decision metrics (rollouts, exploration bonus, backpressure state).
- Use the **Load Timeline** action on a selected profile to stream the last 30 minutes of telemetry buffered by `/datum/ai_telemetry_manager`.
- Gateway health widgets mirror planner/parser queues; if backpressure escalates to `HEAVY` or `CRITICAL`, expect the subsystem to delay further work automatically.

## Responding to Incidents
1. **Unexpected Behavior** (e.g., AI repeating actions):
   - Pull the affected profile’s timeline and inspect `notes` or repeated decisions.
   - If the loop persists, apply a temporary lockdown via the blackboard freeze verb or toggle `ai_control_enabled`.
2. **Player Takeover Reports**:
   - Confirm the timeline shows a `PLAYER_OVERRIDE` state change.
   - Verify reservations cleared; if not, manually cancel them via the debug verbs (future tasks cover direct tooling).
3. **Emergency Alerts**:
   - During red/delta alerts, ensure the exploration multiplier for Security & Emergency displays ~0.6.
   - If scaling fails, reopen the config panel and confirm the emergency modifier sliders.

## Configuration Adjustments
- Launch the **AI Foundation Config** panel from Admin Config TGUI.
- Recommended workflow:
  1. Note current multiplier and safety slider values (tooltips show defaults).
  2. Apply small adjustments (±0.1) and submit.
  3. Observe blackboard telemetry for at least two decision cycles (≈3 s) to validate impact.
- Changes hot-reload through `/datum/ai_control_policy/apply_entry_overrides()`. If values fall outside documented bounds, the policy clamps them; the panel echoes the final applied numbers.

## Rollback & Recovery
- Immediate disable: set the `AI Crew Enabled` toggle to **Off** in the config panel; SS_AI suspends controllers mid-cycle.
- Full rollback: revert to the previous deployment profile using `tgstation-server` and restore the prior config JSON.
- After rollback, confirm:
  - No AI profiles remain active (blackboard should be empty).
  - Planner/parser gateway queues drop to zero within one cycle.

## Telemetry & Audit Trail
- In addition to the in-game timeline stream, decisions are written to `ai_decision_log` (SQL) by the telemetry manager batch job.
- For post-round review:
  - Export the relevant rows filtered by profile_id and timestamp range.
  - Cross-reference with admin config changes (PATCH requests logged via `/admin/ai/config`).
- When investigating potential abuse, retain the 24-hour persistence snapshot before log rotation.

## Known Limitations / To-Do
- Parser/planner services assume localhost reachability; update gateway URLs if running out-of-process.
- Manual verification scenarios (Quickstart) remain pending in this environment; execute them on a staging server before mainline rollout.
- Contract tests (`ai_blackboard_contract.dm`) still require implementation alignment—ensure CI passes before promoting to production.

## Quick Reference Checklist
- [ ] Blackboard shows expected number of AI crew.
- [ ] Backpressure state ≤ `LIGHT` for majority of the round.
- [ ] Telemetry timelines stream without errors for sampled profiles.
- [ ] Config adjustments propagate within two decision cycles.
- [ ] Rollback lever documented and tested prior to live deployment.

