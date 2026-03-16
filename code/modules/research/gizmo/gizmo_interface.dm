/datum/gizmo_interface
	var/list/puzzles = list()

	var/list/possible_active_modes = list(/datum/gizmodes/mood_pulser = 1)
	var/list/guaranteed_active_modes
	var/list/active_modes = list()

	var/min_modes = 1
	var/max_modes = 2

/datum/gizmo_interface/New(holder, trigger_callbacks)
	. = ..()

	trigger_callbacks = generate_interface(holder)

/datum/gizmo_interface/proc/generate_interface(atom/movable/holder)
	. = list()

	var/list/modes_to_spawn = list()
	modes_to_spawn += guaranteed_active_modes

	for(var/i in 1 to (min_modes + rand(min_modes, max_modes)))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		var/datum/gizmodes/mode = new path ()
		mode.generate_modes(.)
		active_modes += mode

	puzzles += new /datum/gizmo_puzzle()

	for(var/datum/gizmo_puzzle/puzzle as anything in puzzles)
		puzzle.generate_code_sequences(.)

/datum/gizmo_interface/beyblade
	possible_active_modes = list(/datum/gizmodes/mood_pulser = 1)
	guaranteed_active_modes = list(/datum/gizmodes/mover)
	min_modes = 0
	max_modes = 1

/datum/gizmo_interface/toggle
	guaranteed_active_modes = list(/datum/gizmodes/lights)
