/datum/element/rust_damage
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
/datum/element/rust_damage/Attach(datum/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(corrupt))

/datum/element/rust_damage/proc/corrupt(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = entered
	if(IS_HERETIC(H))
		return
	H.apply_status_effect(/datum/status_effects/rust_corruption)
