// Cryptic gizmo pulses for Interface Science
#define GIZMO_PULSE_1 "Gizmo Pulse 1"
#define GIZMO_PULSE_2 "Gizmo Pulse 2"
#define GIZMO_PULSE_3 "Gizmo Pulse 3"
#define GIZMO_PULSE_4 "Gizmo Pulse 4"
#define GIZMO_PULSE_5 "Gizmo Pulse 5"
#define GIZMO_PULSE_6 "Gizmo Pulse 6"
#define GIZMO_PULSE_7 "Gizmo Pulse 7"
#define GIZMO_PULSE_8 "Gizmo Pulse 8"

/// From base of /datum/gizactive/start_moving/activate(): ()
#define COMSIG_GIZMO_START_MOVING "gizmo_start_moving"
/// From base of /datum/gizactive/stop_moving/activate(): ()
#define COMSIG_GIZMO_STOP_MOVING "gizmo_stop_moving"

/// From base of /datum/gizactive/lights_on/activate(): ()
#define COMSIG_GIZMO_ON_STATE "gizmo_on_state"
/// From base of /datum/gizactive/lights_off/activate(): ()
#define COMSIG_GIZMO_OFF_STATE "gizmo_off_state"

#define GIZMO_PUZZLE_WRONG 		1
#define GIZMO_PUZZLE_CORRECT	2
#define GIZMO_PUZZLE_SOLVED		3

#define GIZMO_INTERFACE_WIRES "gizmo_interface_wires"
#define GIZMO_INTERFACE_VOICE "gizmo_interface_voices"

#define GIZMO_PICK_ONE "gizmo_pick_one"

/// Common gizmo modes to pick from. They are also weighted so you have even more probability control isnt that cool
#define GIZMO_COMMON_MODES list(\
	/datum/gizmodes/mood_pulser = 1,\
	/datum/gizmodes/mopper = 1,\
	/datum/gizmodes/teleporter = 1,\
	/datum/gizmodes/electric = 1,\
	/datum/gizmodes/dispenser/food = 1,\
	/datum/gizmodes/sputter = 1,\
	/datum/gizmodes/copier = 1,\
)
