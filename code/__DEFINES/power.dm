#define CABLE_LAYER_1 1
#define CABLE_LAYER_2 2
#define CABLE_LAYER_3 4

#define MACHINERY_LAYER_1 1

#define SOLAR_TRACK_OFF     0
#define SOLAR_TRACK_TIMED   1
#define SOLAR_TRACK_AUTO    2

// These two helpers are insane.
// Both powernets and cells use values in real watts and real kilojoules,
// and these conversion helpers include the tickrate conversion.
// That is, an APC draws 5kW of power, and needs to drain the appropriate
// amount of energy from the cell, so it converts 5 kW to 0.01 kJ, twice the
// of joules used per second, but correct because it's including the tickrate
// conversion at the unit step, and all visible use of either unit doesn't
// refer to either unit freshly converted.
// It also obviously breaks with SSfastprocess
// XXX: KILL THIS WITH FIRE, this is begging for delta_time

///conversion ratio from kilojoules to watts
#define WATTS * 1000 / (SSmachines.wait / (1 SECONDS))
///conversion ratio from watts to kilojoules
#define KILOJOULES / 1000 * (SSmachines.wait / (1 SECONDS))

GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

GLOBAL_LIST_EMPTY(powernets)
