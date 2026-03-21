

/datum/gizmo_interface
	var/datum/gizmo_controller/controller
	var/datum/gizmo_puzzle/puzzle = /datum/gizmo_puzzle

	var/list/possible_active_modes = list(/datum/gizmodes/mood_pulser = 1, /datum/gizmodes/mopper = 1)
	var/list/guaranteed_active_modes = list()
	var/list/active_modes = list()

	var/min_modes = 1
	var/max_modes = 2

/datum/gizmo_interface/New(datum/gizmo_controller/_controller)
	. = ..()

	controller = _controller

/datum/gizmo_interface/proc/generate_interface(atom/movable/holder, datum/callback/pulse_callback)
	var/list/trigger_callbacks = list()
	var/list/modes_to_spawn = list() + guaranteed_active_modes

	for(var/i in 1 to (min_modes + rand(min_modes, max_modes)))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		var/datum/gizmodes/mode = new path ()
		mode.generate_modes(trigger_callbacks, src)
		active_modes += mode

	puzzle = new puzzle ()
	puzzle.generate_code_sequences(trigger_callbacks)

/datum/gizmo_interface/beyblade
	possible_active_modes = list(/datum/gizmodes/mood_pulser = 1)
	guaranteed_active_modes = list(/datum/gizmodes/mover)
	min_modes = 0
	max_modes = 1

/datum/gizmo_interface/toggle
	guaranteed_active_modes = list(/datum/gizmodes/lights)

/datum/gizmo_interface/voice_unlock
	guaranteed_active_modes = list(/datum/gizmodes/voice)
	min_modes = 0
	max_modes = 0

