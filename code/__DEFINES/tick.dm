#define TICK_LIMIT_RUNNING 90
#define TICK_LIMIT_TO_RUN 85
#define TICK_LIMIT_MC 84
#define TICK_LIMIT_MC_INIT 100

#define TICK_CHECK ( world.tick_usage > CURRENT_TICKLIMIT ? stoplag() : 0 )
#define CHECK_TICK if (world.tick_usage > CURRENT_TICKLIMIT)  stoplag()
