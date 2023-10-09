/**
 * ## death linkage element!
 *
 * Bespoke element that when the owner dies, the linked mob dies too.
 */
/datum/element/death_linked
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	///The mob that also dies when the user dies
	var/datum/weakref/linked_mob

/datum/element/death_linked/Attach(datum/target, mob/living/target_mob)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!target_mob)
		stack_trace("[type] added to [target] with NO MOB.")
	src.linked_mob = WEAKREF(target_mob)
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_linked/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_linked/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/mob/living/linked_mob_resolved = linked_mob?.resolve()
	linked_mob_resolved?.death(TRUE)
