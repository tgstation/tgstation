/**
 * ## death drops element!
 *
 * bespoke element that spawn can spawn one or multiple objects when a mob is killed
 */
/datum/element/death_drops
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///what items the target drops when killed
	var/list/loot

/datum/element/death_drops/Attach(datum/target, list/loot)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!loot)
		stack_trace("[type] added to [target] with NO LOOT.")
	src.loot = loot
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_drops/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_drops/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	for(var/thing_to_spawn in loot)
		if(loot[thing_to_spawn]) //If this is an assoc list, use the value of that to get the right amount
			for(var/index in 1 to loot[thing_to_spawn])
				new thing_to_spawn(target.drop_location())
		else
			new thing_to_spawn(target.drop_location())
