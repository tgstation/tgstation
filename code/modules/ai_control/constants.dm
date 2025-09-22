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

GLOBAL_DATUM(ai_control_policy, /datum/ai_control_policy)

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

/// Tick usage thresholds (percentage of a tick) for backpressure decisions.
#define AI_TICK_USAGE_SOFT_CAP 90
#define AI_TICK_USAGE_HARD_CAP 92
#define AI_TICK_USAGE_CRITICAL 97

/// Backpressure modes exposed by the AI subsystem.
#define AI_BACKPRESSURE_NONE 0
#define AI_BACKPRESSURE_LIGHT 1
#define AI_BACKPRESSURE_HEAVY 2
#define AI_BACKPRESSURE_CRITICAL 3

/// Controller processing allowances per subsystem cycle.
#define AI_CONTROLLERS_PER_TICK_NORMAL 6
#define AI_CONTROLLERS_PER_TICK_LIGHT 4
#define AI_CONTROLLERS_PER_TICK_HEAVY 2
#define AI_CONTROLLERS_PER_TICK_CRITICAL 0

/// Gateway queue helpers.
#define AI_GATEWAY_CHANNEL_PLANNER "planner"
#define AI_GATEWAY_CHANNEL_PARSER "parser"

#define AI_GATEWAY_PRIORITY_HIGH 1
#define AI_GATEWAY_PRIORITY_NORMAL 5
#define AI_GATEWAY_PRIORITY_LOW 9

#define AI_GATEWAY_INFLIGHT_NORMAL 4
#define AI_GATEWAY_INFLIGHT_LIGHT 3
#define AI_GATEWAY_INFLIGHT_HEAVY 2
#define AI_GATEWAY_INFLIGHT_CRITICAL 0

/// Default planner/parser endpoints and dispatch tuning.
#define AI_GATEWAY_DEFAULT_PLANNER_URL "http://127.0.0.1:15151/plan"
#define AI_GATEWAY_DEFAULT_PARSER_URL "http://127.0.0.1:15152/parse"
#define AI_GATEWAY_DEFAULT_TIMEOUT_DS 50
#define AI_GATEWAY_DEFAULT_RETRY_DS 20

/// Backoff applied when the subsystem reports elevated tick usage.
#define AI_GATEWAY_BACKOFF_LIGHT_DS 10
#define AI_GATEWAY_BACKOFF_HEAVY_DS 30
#define AI_GATEWAY_BACKOFF_CRITICAL_DS 50

/// Option runner state identifiers.
#define AI_OPTION_STATE_IDLE 0
#define AI_OPTION_STATE_RUNNING 1
#define AI_OPTION_STATE_COMPLETE 2
#define AI_OPTION_STATE_ABORTED 3

/// Option scoring helpers.
#define AI_OPTION_PRIORITY_DEFAULT 5
#define AI_OPTION_DEFAULT_TIMEOUT_DS 50

/// Feature flag helper until dedicated config entries are wired.
#define AI_CREW_ENABLED (GLOB.ai_control_policy && GLOB.ai_control_policy.enabled)

/// Blackboard buffer sizing + logging helpers.
#define AI_BLACKBOARD_LOCAL_EVENT_LIMIT 10
#define AI_BLACKBOARD_RADIO_EVENT_LIMIT 10
#define AI_BLACKBOARD_ALERT_EVENT_LIMIT 10

#define AI_PERCEPTION_LOG_PREFIX "AI_PERCEPTION "
