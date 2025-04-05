/// Camouflage us when we enter space by increasing alpha and or changing color
/datum/component/space_camo
	/// Alpha we have in space
	var/space_alpha
	/// Alpha we have elsewhere
	var/non_space_alpha
	/// How long we can't enter camo after hitting or being hit
	var/reveal_after_combat
	/// The world time after we can camo again
	VAR_PRIVATE/next_camo

/datum/component/space_camo/Initialize(space_alpha, non_space_alpha, reveal_after_combat)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.space_alpha = space_alpha
	src.non_space_alpha = non_space_alpha
	src.reveal_after_combat = reveal_after_combat

	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))

	if(isliving(parent))
		RegisterSignals(parent, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_REVEAL), PROC_REF(force_exit_camo))

/datum/component/space_camo/proc/on_atom_entering(atom/movable/entering, atom/entered)
	SIGNAL_HANDLER

	if(!attempt_enter_camo())
		exit_camo(parent)

/datum/component/space_camo/proc/attempt_enter_camo()
	if(!isspaceturf(get_turf(parent)) || next_camo > world.time)
		return FALSE

	enter_camo(parent)
	return TRUE

/datum/component/space_camo/proc/force_exit_camo()
	SIGNAL_HANDLER

	exit_camo(parent)
	next_camo = world.time + reveal_after_combat
	addtimer(CALLBACK(src, PROC_REF(attempt_enter_camo)), reveal_after_combat, TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/component/space_camo/proc/enter_camo(atom/movable/parent)
	if(parent.alpha != space_alpha)
		animate(parent, alpha = space_alpha, time = 0.5 SECONDS)
	parent.remove_from_all_data_huds()
	parent.add_atom_colour(SSparallax.get_parallax_color(), TEMPORARY_COLOUR_PRIORITY)

/datum/component/space_camo/proc/exit_camo(atom/movable/parent)
	animate(parent, alpha = non_space_alpha, time = 0.5 SECONDS)
	parent.add_to_all_human_data_huds()
	parent.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
