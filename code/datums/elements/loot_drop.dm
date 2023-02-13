v/**
 * # Loot on Death element
 *
 * A mob with this element will create the provided atoms when it dies.
 */
/datum/element/loot_drop
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// List of typepaths of atoms to create
	var/list/loot
	/// If true we remove the element after loot is created to prevent weird kill/revive loops
	var/only_once

/datum/element/loot_drop/Attach(datum/target, list/loot = list(), only_once = FALSE)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.loot = loot
	src.only_once = only_once
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(check_death))

/datum/element/loot_drop/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_STATCHANGE)

/datum/element/loot_drop/proc/check_death(mob/living/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if (new_stat != DEAD || old_stat == DEAD)
		return
	for (var/typepath in loot)
		new typepath(source.loc)
	if (only_once)
		source.RemoveElement(/datum/element/loot_drop)
