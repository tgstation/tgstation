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

//fancy math for calculating cost in ms from tick_usage percentage and the length of ticks
//percent_of_tick_used * (ticklag * 100(to convert to ms)) / 100(precent ratio)
//collapsed to precent_of_tick_used * tick_lag
#define TICK_USAGE_TO_MS(percent_of_tick_used) (percent_of_tick_used * world.tick_lag)