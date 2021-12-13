/// Minimum percentage of tick to leave for the master controller to run on.
/// if everything else uses >= (100 - MAPTICK_MC_MIN_RESERVE) percent of the tick, time dilation should increase
#define MAPTICK_MC_MIN_RESERVE 70
#define MAPTICK_LAST_INTERNAL_TICK_USAGE (world.map_cpu)

/// Extra percentage of the tick given to non MC processes when calculating how much time the MC has to use
#define TICK_BYOND_RESERVE 2
/// Tick limit while running normally
#define TICK_LIMIT_RUNNING (max(100 - TICK_BYOND_RESERVE - MAPTICK_LAST_INTERNAL_TICK_USAGE, MAPTICK_MC_MIN_RESERVE))
/// Tick limit used to resume things in stoplag
#define TICK_LIMIT_TO_RUN 70
/// Tick limit for MC while running
#define TICK_LIMIT_MC 70
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
