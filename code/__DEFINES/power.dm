#define CABLE_LAYER_1 (1<<0)
#define CABLE_LAYER_2 (1<<1)
#define CABLE_LAYER_3 (1<<2)

#define MACHINERY_LAYER_1 (1<<0)
#define MACHINERY_LAYER_2 (1<<1)
#define MACHINERY_LAYER_3 (1<<2)

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
	"[CABLE_LAYER_1]" = "Cable Layer 1",
	"[CABLE_LAYER_2]" = "Cable Layer 2",
	"[CABLE_LAYER_3]" = "Cable Layer 3"
))

// Converts machine layer name to its value
GLOBAL_LIST_INIT(machinery_layer_to_value, list(
	"Machine Layer 1" = MACHINERY_LAYER_1,
	"Machine Layer 2" = MACHINERY_LAYER_2,
	"Machine Layer 3" = MACHINERY_LAYER_3
))

// Converts machine layer to human readable name
GLOBAL_LIST_INIT(machinery_layer_to_name, list(
	"[MACHINERY_LAYER_1]" = "Machine Layer 1",
	"[MACHINERY_LAYER_2]" = "Machine Layer 2",
	"[MACHINERY_LAYER_3]" = "Machine Layer 3"
))
