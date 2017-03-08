#define PI						3.1415
#define SPEED_OF_LIGHT			3e8		//not exact but hey!
#define SPEED_OF_LIGHT_SQ		9e+16
#define INFINITY				1e31	//closer then enough

//atmos
#define R_IDEAL_GAS_EQUATION	8.31	//kPa*L/(K*mol)
#define ONE_ATMOSPHERE			101.325	//kPa
#define T0C						273.15	// 0degC
#define T20C					293.15	// 20degC
#define TCMB					2.7		// -270.3degC

//"fancy" math for calculating time in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(percent ratio)
//collapsed to percent_of_tick_used * tick_lag
#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)
#define TICK_USAGE_TO_MS(starting_tickusage) (TICK_DELTA_TO_MS(world.tick_usage-starting_tickusage))

#define PERCENT(val) (round(val*100, 0.1))
#define CLAMP01(x) (Clamp(x, 0, 1))

//time of day but automatically adjusts to the server going into the next day within the same round.
//for when you need a reliable time number that doesn't depend on byond time.
#define REALTIMEOFDAY (world.timeofday + (MIDNIGHT_ROLLOVER * MIDNIGHT_ROLLOVER_CHECK))
#define MIDNIGHT_ROLLOVER_CHECK ( rollovercheck_last_timeofday != world.timeofday ? update_midnight_rollover() : midnight_rollovers )
