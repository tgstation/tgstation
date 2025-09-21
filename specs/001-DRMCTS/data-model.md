# Data Model: AI-Controlled Human Crew Foundation

## Overview
The module introduces structured datums to represent each AI-controlled human, the situational data they consume, and the telemetry/admin configuration required by the spec.

## Entities

### AI Crew Profile (`/datum/ai_crew_profile`)
- **Key Fields**
  - `mob_ref` (weakref to `/mob/living/carbon/human`)
  - `job_id` (string job identifier)
  - `duty_objectives` (list of `/datum/ai_duty_objective`)
  - `action_taxonomy_weights` (assoc list: action category → float multiplier)
  - `risk_tolerance` (enum: cautious, normal, assertive)
  - `status_flags` (bitfield: `AI_ACTIVE`, `PLAYER_OVERRIDE`, `EMERGENCY_LOCKDOWN`, etc.)
  - `last_action` (struct with verb id, timestamp, outcome)
  - `pending_orders` (queue of high-priority directives from players/admins)
- **Relationships**
  - One-to-many with `Decision Telemetry Record`
  - Many-to-one with `Administrator Control Policy`
  - Aggregates `Situational Context Snapshot` each evaluation tick
- **Validation Rules**
  - `mob_ref` must resolve to alive human not controlled by player
  - `action_taxonomy_weights` must contain all five categories with sum within [2.5, 7.5]
  - `status_flags` cannot include `AI_ACTIVE` when `PLAYER_OVERRIDE` set

### AI Duty Objective (`/datum/ai_duty_objective`)
- **Fields**
  - `id` (string)
  - `description` (string)
  - `priority` (1-5)
  - `validation_proc` (proc path verifying completion)
  - `cooldown` (ticks)
- **Relationships**
  - Owned by `AI Crew Profile`
- **Validation**
  - `priority` must be unique per profile to avoid ties

### Situational Context Snapshot (`/datum/ai_context_snapshot`)
- **Fields**
  - `timestamp`
  - `location` (`/turf`) + zone metadata
  - `nearby_entities` (list of typed refs with threat/friendliness scores)
  - `environmental_alerts` (list of active station alerts affecting heuristics)
  - `available_equipment` (list with reservation status)
  - `player_orders` (list of latest direct commands with expiration)
- **Relationships**
  - Generated per evaluation cadence by `AI Crew Profile`
  - Shared reference to `Administrator Control Policy` for thresholds
- **Validation**
  - Snapshots must expire after 5 seconds to avoid stale decisions

### Decision Telemetry Record (`/datum/ai_decision_telemetry`)
- **Fields**
  - `profile_id`
  - `sequence_id` (monotonic increasing)
  - `candidate_actions` (list of structs with `verb`, `Q`, `prior`, `visit_count`)
  - `selected_action`
  - `exploration_bonus` (float)
  - `rollout_count` (int)
  - `result` (enum: success, partial, failure, aborted)
  - `notes` (string for anomaly logging)
- **Relationships**
  - Linked list per profile for 30-minute retention buffer
  - Exported to telemetry stream consumed by TGUI blackboard
- **Validation**
  - `rollout_count` ≤ 200 per FR-002
  - `exploration_bonus` clamp to ±5 to avoid numeric overflow

### Administrator Control Policy (`/datum/ai_control_policy`)
- **Fields**
  - `action_category_defaults` (assoc list of category → `c_pi` base)
  - `emergency_modifiers` (struct describing alert-level scaling)
  - `safety_thresholds` (max hazard rating before abort)
  - `task_queue_limit` (per-profile outstanding tasks cap)
  - `telemetry_retention_minutes`
  - `rate_limits` (struct for item toggles, interaction frequency)
- **Relationships**
  - Persistent config entry accessible via Admin Config subsystem
  - Referenced by AI Crew Profiles at runtime
- **Validation**
  - `telemetry_retention_minutes` default 30, min 10, max 120
  - `task_queue_limit` ≥ 1; `action_category_defaults[Security & Emergency]` ≤ 1.0

### Equipment Reservation (`/datum/ai_equipment_reservation`)
- **Fields**
  - `equipment_ref`
  - `reserved_by` (profile id)
  - `priority_score`
  - `expires_at`
- **Relationships**
  - Managed by shared subsystem to prevent conflicts
- **Validation**
  - `expires_at` within 5 seconds unless renewed by active profile

## State Transitions
- **AI Activation**: Eligible `mob` → create profile → load policy defaults → set `AI_ACTIVE`
- **Action Execution Loop**: Snapshot context → evaluate MCTS → reserve equipment → execute → emit telemetry → prune old telemetry (>30 minutes)
- **Player Takeover**: Clear reservations → flush queued actions → set `PLAYER_OVERRIDE` flag → drop AI subsystems
- **Emergency Escalation**: Detect alert → update policy overrides → lower `c_pi` for Security & Emergency to 0.6 → restore when alert clears

## Data Persistence
- Runtime datums live in memory; telemetry aggregates stored via `SSdbcore` table `ai_decision_log` with 24-hour retention job. Config defaults stored in `/config/ai_foundation.json` and mirrored in admin UI.

