/datum/element/effect_trail
	var/obj/effect/chosen_effect

/datum/element/effect_trail/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_carpet))

/datum/element/effect_trail/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/// Generates a trail of cosmig fields
/datum/element/effect_trail/proc/generate_carpet(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(target_object)
	if(istype(open_turf))
		new chosen_effect(open_turf)

/datum/element/effect_trail/cosmig_trail
	chosen_effect = /obj/effect/forcefield/cosmic_field/fast
