#define TICK_LIMIT_RUNNING 90
#define TICK_LIMIT_TO_RUN 85
#define TICK_LIMIT_MC 80

#if DM_VERSION >= 510
#define TICK_CHECK ( world.tick_usage > TICK_LIMIT_RUNNING ? stoplag() : 0 )
#define CHECK_TICK if (world.tick_usage > TICK_LIMIT_RUNNING)  stoplag()
#define MC_TICK_CHECK ( world.tick_usage > TICK_LIMIT_RUNNING ? pause() : 0 )
#else
#define TICK_CHECK ( 0 )
#define CHECK_TICK
#define MC_TICK_CHECK ( 0 )
#endif
