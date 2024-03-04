#define CABLE_LAYER_ALL ALL
#define CABLE_LAYER_1 (1<<0)
	#define CABLE_LAYER_1_NAME "Red Power Line"
#define CABLE_LAYER_2 (1<<1)
	#define CABLE_LAYER_2_NAME "Yellow Power Line"
#define CABLE_LAYER_3 (1<<2)
	#define CABLE_LAYER_3_NAME "Blue Power Line"

#define SOLAR_TRACK_OFF 0
#define SOLAR_TRACK_TIMED 1
#define SOLAR_TRACK_AUTO 2

///conversion ratio from joules to watts
#define WATTS / 0.002
///conversion ratio from watts to joules
#define JOULES * 0.002

GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

// Converts cable layer to its human readable name
GLOBAL_LIST_INIT(cable_layer_to_name, list(
	"[CABLE_LAYER_1]" = CABLE_LAYER_1_NAME,
	"[CABLE_LAYER_2]" = CABLE_LAYER_2_NAME,
	"[CABLE_LAYER_3]" = CABLE_LAYER_3_NAME
))

// Converts cable color name to its layer
GLOBAL_LIST_INIT(cable_name_to_layer, list(
	CABLE_LAYER_1_NAME = CABLE_LAYER_1,
	CABLE_LAYER_2_NAME = CABLE_LAYER_2,
	CABLE_LAYER_3_NAME = CABLE_LAYER_3
))

