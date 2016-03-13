#if DM_VERSION >= 510
#define TICK_CHECK ( world.tick_usage > 85 ? pause1tick() : 0 )
#define CHECK_TICK if (world.tick_usage > 85)  pause1tick()
#define MC_TICK_CHECK ( world.tick_usage > 85 ? pause() : 0 )
#else
#define TICK_CHECK ( 0 )
#define CHECK_TICK
#define MC_TICK_CHECK ( 0 )
#endif