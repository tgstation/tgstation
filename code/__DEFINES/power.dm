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

///The watt is the standard unit of power for this codebase.
#define WATT 1
///The joule is the standard unit of energy for this codebase.
#define JOULE 1
///The watt is the standard unit of power for this codebase.
#define WATTS * WATT
///The joule is the standard unit of energy for this codebase.
#define JOULES * JOULE

///The amount of energy, in joules, a standard powercell has.
#define STANDARD_CELL_CHARGE (1e6 JOULES) // 1 MJ.

GLOBAL_VAR_INIT(CHARGELEVEL, 0.01) // Cap for how fast cells charge, as a percentage per second (.01 means cellcharge is capped to 1% per second)

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

