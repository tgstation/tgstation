/datum/element/extinguisher_tile

/datum/element/extinguisher_tile/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(extinguish_entity))

/datum/element/extinguisher_tile/Detach(turf/source)
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	return ..()

/datum/element/extinguisher_tile/proc/extinguish_entity(atom/source, atom/movable/entered)
	if(isliving(entered))
		var/mob/living/our_mob = entered
		our_mob.extinguish_mob()

	if(isitem(entered))
		to_chat("put out burning paper")
