/*
 * An element used for making a trail of effects appear behind a movable atom when it moves.
 */

/datum/element/effect_trail
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The effect used for the trail generation.
	var/chosen_effect

/datum/element/effect_trail/Attach(datum/target, chosen_effect = /obj/effect/forcefield/cosmic_field)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_effect))
	src.chosen_effect = chosen_effect

/datum/element/effect_trail/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/// Generates an effect
/datum/element/effect_trail/proc/generate_effect(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(target_object)
	if(istype(open_turf))
		new chosen_effect(open_turf)
