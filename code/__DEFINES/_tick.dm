/// Percentage of tick to leave for master controller to run
#define MAPTICK_MC_MIN_RESERVE 60
/// internal_tick_usage is updated every tick by extools
#define MAPTICK_LAST_INTERNAL_TICK_USAGE ((Master.normalized_internal_tick_usage / world.tick_lag) * 100)
/// Amount of a tick to reserve for byond regardless of its reported internal_tick_usage
#define TICK_BYOND_RESERVE 2
/// Tick limit while running normally
#define TICK_LIMIT_RUNNING (max(TICK_LIMIT_RUNNING_BACKGROUND, MAPTICK_MC_MIN_RESERVE))
/// Tick limit for background things, strictly obeys the internal_tick_usage metric
#define TICK_LIMIT_RUNNING_BACKGROUND (100 - TICK_BYOND_RESERVE - MAPTICK_LAST_INTERNAL_TICK_USAGE)
/// Precent of a tick to require to even bother running anything. (10 percent of the tick_limit_running by default)
#define TICK_MIN_RUNTIME (TICK_LIMIT_RUNNING * 0.1)
/// Tick limit used to resume things in stoplag
#define TICK_LIMIT_TO_RUN (Master.current_ticklimit - TICK_MIN_RUNTIME)
/// Tick limit for MC while running
#define TICK_LIMIT_MC (TICK_LIMIT_RUNNING - TICK_MIN_RUNTIME)
/// Tick limit while initializing
#define TICK_LIMIT_MC_INIT_DEFAULT (100 - TICK_BYOND_RESERVE)

/// for general usage of tick_usage
#define TICK_USAGE world.tick_usage
/// to be used where the result isn't checked
#define TICK_USAGE_REAL world.tick_usage

/// Returns true if tick_usage is above the limit
#define TICK_CHECK ( TICK_USAGE > Master.current_ticklimit )
/// runs stoplag if tick_usage is above the limit
#define CHECK_TICK ( TICK_CHECK ? stoplag() : 0 )

/// Returns true if tick usage is above 95, for high priority usage
#define TICK_CHECK_HIGH_PRIORITY ( TICK_USAGE > 95 )
/// runs stoplag if tick_usage is above 95, for high priority usage
#define CHECK_TICK_HIGH_PRIORITY ( TICK_CHECK_HIGH_PRIORITY? stoplag() : 0 )
