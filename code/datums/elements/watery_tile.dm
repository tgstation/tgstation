/datum/element/watery_tile
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/watery_tile/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(extinguish_atom))

/datum/element/watery_tile/Detach(turf/source)
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	return ..()

/datum/element/watery_tile/proc/extinguish_atom(atom/source, atom/movable/entered)
	SIGNAL_HANDLER

	entered.extinguish()
	if(isliving(entered))
		var/mob/living/our_mob = entered
		our_mob.adjust_wet_stacks(3)
