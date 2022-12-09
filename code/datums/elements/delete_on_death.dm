/**
 * ## delete on death
 *
 * element that deletes the mob on death
 */
/datum/element/delete_on_death/Attach(datum/target, list/loot)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/delete_on_death/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/delete_on_death/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	qdel(target)
