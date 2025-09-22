#ifndef AI_FOUNDATION_CONSTANTS_SHARED
#define AI_FOUNDATION_CONSTANTS_SHARED

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

/// Backoff applied when the subsystem reports elevated tick usage.
#define AI_GATEWAY_BACKOFF_LIGHT_DS 10
#define AI_GATEWAY_BACKOFF_HEAVY_DS 30
#define AI_GATEWAY_BACKOFF_CRITICAL_DS 50

/// Feature flag helper until dedicated config entries are wired.
#define AI_CREW_ENABLED (GLOB.ai_control_policy && GLOB.ai_control_policy.enabled)

#endif
