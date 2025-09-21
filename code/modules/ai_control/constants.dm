/// Shared constants and helpers for the AI-Controlled Human Crew Foundation module.

#define AI_CONTROL_CONFIG_PATH "config/ai_foundation.json"

/// Default cadence (seconds) for evaluation loop per FR-002.
#define AI_CONTROL_DEFAULT_CADENCE 1.5
/// Maximum number of rollouts per decision cycle.
#define AI_CONTROL_DEFAULT_MAX_ROLLOUTS 200

/// Action taxonomy category identifiers.
#define AI_ACTION_CATEGORY_ROUTINE "Routine Upkeep"
#define AI_ACTION_CATEGORY_LOGISTICS "Maintenance & Logistics"
#define AI_ACTION_CATEGORY_MEDICAL "Medical Response"
#define AI_ACTION_CATEGORY_SECURITY "Security & Emergency"
#define AI_ACTION_CATEGORY_SUPPORT "Social & Support"

GLOBAL_LIST_INIT(ai_control_action_categories, list(
    AI_ACTION_CATEGORY_ROUTINE,
    AI_ACTION_CATEGORY_LOGISTICS,
    AI_ACTION_CATEGORY_MEDICAL,
    AI_ACTION_CATEGORY_SECURITY,
    AI_ACTION_CATEGORY_SUPPORT
))

GLOBAL_LIST_INIT(ai_control_default_multipliers, list(
    AI_ACTION_CATEGORY_ROUTINE = 1.6,
    AI_ACTION_CATEGORY_LOGISTICS = 1.35,
    AI_ACTION_CATEGORY_MEDICAL = 0.9,
    AI_ACTION_CATEGORY_SECURITY = 0.8,
    AI_ACTION_CATEGORY_SUPPORT = 1.1
))

/// Risk tolerance labels for AI crew profiles.
#define AI_RISK_TOLERANCE_CAUTIOUS "cautious"
#define AI_RISK_TOLERANCE_NORMAL "normal"
#define AI_RISK_TOLERANCE_ASSERTIVE "assertive"

/// Status flag bitfields for AI crew profiles.
#define AI_CREW_STATUS_ACTIVE (1<<0)
#define AI_CREW_STATUS_PLAYER_OVERRIDE (1<<1)
#define AI_CREW_STATUS_EMERGENCY_LOCKDOWN (1<<2)

/// Safety + telemetry bounds.
#define AI_CONTROL_DEFAULT_TASK_QUEUE_LIMIT 4
#define AI_CONTROL_MIN_TELEMETRY_MINUTES 10
#define AI_CONTROL_DEFAULT_TELEMETRY_MINUTES 30
#define AI_CONTROL_MAX_TELEMETRY_MINUTES 120

#define AI_CONTROL_DEFAULT_MAX_HAZARD 0.65
#define AI_CONTROL_DEFAULT_MAX_CHAIN_FAILURES 2

#define AI_CONTROL_DEFAULT_ITEM_TOGGLE_RATE 5
#define AI_CONTROL_DEFAULT_AGGRESSIVE_RATE 8

/// Reservation defaults in ticks.
#define AI_CONTROL_DEFAULT_RESERVATION_SECONDS 5
#define AI_CONTROL_DEFAULT_RESERVATION_RETRY_SECONDS 3

/// Exploration bonus clamp (matches spec requirement ±5).
#define AI_CONTROL_EXPLORATION_BONUS_MAX 5

/// Snapshot time-to-live (5 seconds).
#define AI_CONTEXT_SNAPSHOT_TTL (5 SECONDS)
