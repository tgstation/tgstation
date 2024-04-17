/datum/element/watery_tile

/datum/element/watery_tile/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(extinguish_atom))

/datum/element/watery_tile/Detach(turf/source)
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	return ..()

/datum/element/watery_tile/proc/extinguish_atom(atom/source, atom/movable/entered)
	if(!isatom(entered))
		return
	entered.extinguish()
