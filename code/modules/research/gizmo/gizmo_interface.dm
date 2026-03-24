#define GIZMO_COMMON_MODES list(\
	/datum/gizmodes/mood_pulser = 1,\
	/datum/gizmodes/mopper = 1,\
	/datum/gizmodes/teleporter = 1,\
)

// ideeën:
// stroom suck en disperse (bliksem, emp?)
// visuele effecten maker (misschien op een speciale locatie? met usb?)
//

/// Essentially a small wrapper that holds the puzzle datum and connects it with the operating modes of the machine
/datum/gizmo_interface
	var/datum/gizmo_controller/controller
	var/datum/gizmo_puzzle/puzzle = /datum/gizmo_puzzle

	var/list/possible_active_modes = GIZMO_COMMON_MODES
	var/list/guaranteed_active_gizpulses = list()
	var/list/active_gizpulses = list()

	var/min_modes = 1
	var/max_modes = 2

/datum/gizmo_interface/New(datum/gizmo_controller/_controller)
	. = ..()

	controller = _controller

/datum/gizmo_interface/proc/generate_interface(atom/movable/holder, datum/callback/pulse_callback)
	var/list/trigger_callbacks = list()
	var/list/modes_to_spawn = list() + guaranteed_active_gizpulses

	for(var/i in 1 to (min_modes + rand(min_modes, max_modes)))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		var/datum/gizmodes/mode = new path ()
		mode.generate_modes(trigger_callbacks, src)
		active_gizpulses += mode

	puzzle = new puzzle ()
	puzzle.generate_code_sequences(trigger_callbacks)

/// Moves around. Guaranteed to have a mode that controles the movement
/datum/gizmo_interface/beyblade
	guaranteed_active_gizpulses = list(/datum/gizmodes/mover)
	min_modes = 0
	max_modes = 1

/// Guaranteed to have a lights mode
/datum/gizmo_interface/toggle
	guaranteed_active_gizpulses = list(/datum/gizmodes/lights)

/// Guaranteed to have a mode that will give a voice components secret keywords. Assumes there's a voice interface added by the gizmo_controller
/datum/gizmo_interface/voice_unlock
	guaranteed_active_gizpulses = list(/datum/gizmodes/voice)
	min_modes = 0
	max_modes = 0

