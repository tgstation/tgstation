/datum/gizmo_interface
	var/list/puzzles = list()

	var/list/possible_active_modes = list(/datum/gizmodes/mood_pulser)
	var/list/active_modes = list()

/datum/gizmo_interface/New(holder, trigger_callbacks)
	. = ..()

	trigger_callbacks = generate_interface(holder)

/datum/gizmo_interface/proc/generate_interface(atom/movable/holder)
	. = list()

	for(var/path in possible_active_modes)
		var/datum/gizmodes/mode = new path ()
		mode.generate_modes(.)

		active_modes += mode

	puzzles += new /datum/gizmo_puzzle()

	for(var/datum/gizmo_puzzle/puzzle as anything in puzzles)
		puzzle.generate_code_sequences(.)


