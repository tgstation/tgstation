#define CABLE_LAYER_1 1
#define CABLE_LAYER_2 2
#define CABLE_LAYER_3 4

#define MACHINERY_LAYER_1 1

#define SOLAR_TRACK_OFF     0
#define SOLAR_TRACK_TIMED   1
#define SOLAR_TRACK_AUTO    2

///conversion ratio from joules to watts
#define WATTS / 0.002
///conversion ratio from watts to joules
#define JOULES * 0.002

GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

GLOBAL_LIST_EMPTY(powernets)
