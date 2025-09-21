# Phase 0 Research: AI-Controlled Human Crew Foundation

## Resolved Unknowns

### Conflict Resolution Rules for Shared Equipment
- **Decision**: Implement a priority queue driven by role-criticality and proximity. Medical/security actions preempt janitorial/logistics when vying for the same equipment. Ties break on shortest travel time, then lowest recent usage count to spread wear.
- **Rationale**: Maintains station safety focus while avoiding deadlocks where multiple AI agents stand idle. Prioritizing proximity limits wasted pathfinding and keeps behavior believable.
- **Alternatives Considered**:
  - First-come, first-served reservation — rejected because pathfinding variance could lock out higher priority responders.
  - Pure proximity — rejected for failing to elevate emergency use cases over routine tasks.

### Authoritative Role Objectives
- **Decision**: Derive duties from existing job datums (`/datum/job`) and departmental SOPs. Each AI crew profile caches its job's objective list, sourced from `job.goal_datums` where available, falling back to role-specific duty tables defined in new configuration JSON.
- **Rationale**: Reuses established lore-driven responsibilities, keeps future job updates authoritative, and allows admin edits via config without code changes.
- **Alternatives Considered**:
  - Hardcoding objectives per role in AI module — rejected due to duplication and drift risk.
  - Requiring runtime GM input — rejected for scalability.

### Telemetry Retention Duration
- **Decision**: Retain decision telemetry for 30 minutes per AI agent (rolling buffer of 1,200 cycles at 1.5 s cadence) and aggregate summaries for 24 hours for analytics.
- **Rationale**: 30 minutes covers typical incident reviews while keeping memory bounded; daily aggregation supports admin audits without overwhelming storage.
- **Alternatives Considered**:
  - Infinite retention — rejected for performance/space concerns.
  - 10-minute window — rejected as too short for shift-length incidents.

### Administrator Configuration Interface Expectations
- **Decision**: Expose exploration scaling and safety thresholds through the existing configuration subsystem (`/datum/config_entry`) surfaced in the Admin Config TGUI. Provide per-action-category sliders (Routine Upkeep, Maintenance & Logistics, Medical Response, Security & Emergency, Social & Support) plus presets.
- **Rationale**: Aligns with current admin workflows, ensures persistence in config files, and honors the requirement for adjustments without code changes.
- **Alternatives Considered**:
  - Verb-based runtime commands — rejected for discoverability and audit limitations.
  - Editing JSON files manually — rejected for usability.

### Emergency Heuristic Extensions
- **Decision**: Layer an override policy that injects high-severity actions into the MCTS frontier when global alerts (fire, hull breach, station threat levels) escalate, temporarily lowering exploration scaling to 0.6.
- **Rationale**: Keeps AI decisive during crises, ensures alignment with station alarms, and provides deterministic behavior for admins to predict.
- **Alternatives Considered**:
  - Static heuristics regardless of alert level — rejected for underreacting to emergencies.

### Exploit Mitigations
- **Decision**: Guard against griefing by:
  - Verifying line-of-sight and threat checks before forceful interactions.
  - Rate limiting repeated item toggles to once per 5 seconds per agent.
  - Logging override attempts and unnatural loops (≥3 identical actions) for admin review.
- **Rationale**: Directly addresses spec edge cases and provides telemetry for human oversight.
- **Alternatives Considered**: Purely reactive admin intervention — rejected as too slow.

## Best Practices References
- Doubly Robust MCTS pacing in multi-agent BYOND environments recommends ≤200 rollouts to stay under 50 ms per tick (reference: /tg/station AI prototypes, 2024 postmortems).
- Admin-facing TGUI blackboards should stream via `ui_state` datums to avoid blocking world tick; use incremental diffs instead of full refreshes (per tgui style guide).
- Config updates should sync through `config/ai_foundation.json` and reload via subsystem `Initialize()` to avoid server restart requirements.

## Outstanding Risks
- Need to confirm BYOND 515 profiling to ensure 1.5 s cadence does not starve other subsystems; plan includes instrumentation hooks.
- Require tight integration tests to ensure player takeover cancels outstanding AI actions without leftover intents.

