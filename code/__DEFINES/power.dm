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

///The watt is the standard unit of power for this codebase. Do not change this.
#define WATT 1
///The joule is the standard unit of energy for this codebase. Do not change this.
#define JOULE 1
///The watt is the standard unit of power for this codebase. You can use this with other defines to clarify that it will be multiplied by time.
#define WATTS * WATT
///The joule is the standard unit of energy for this codebase. You can use this with other defines to clarify that it will not be multiplied by time.
#define JOULES * JOULE

///The capacity of a standard power cell
#define STANDARD_CELL_VALUE (10 KILO)
	///The amount of energy, in joules, a standard powercell has.
	#define STANDARD_CELL_CHARGE (STANDARD_CELL_VALUE JOULES) // 10 KJ.
	///The amount of power, in watts, a standard powercell can give.
	#define STANDARD_CELL_RATE (STANDARD_CELL_VALUE WATTS) // 10 KW.

/// Capacity of a standard battery
#define STANDARD_BATTERY_VALUE (STANDARD_CELL_VALUE * 100)
	/// The amount of energy, in joules, a standard battery has.
	#define STANDARD_BATTERY_CHARGE (STANDARD_BATTERY_VALUE JOULES) // 1 MJ
	/// The amount of energy, in watts, a standard battery can give.
	#define STANDARD_BATTERY_RATE (STANDARD_BATTERY_VALUE WATTS) // 1 MW

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

