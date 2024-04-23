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
	///callback to decide what drops when killed, if the logic is more advanced
	var/datum/callback/on_death_callback

/datum/element/death_drops/Attach(datum/target, list/loot, on_death_callback = null)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!loot && !on_death_callback)
		stack_trace("[type] added to [target] with NO LOOT or callback to decide loot.")
	src.loot = loot
	src.on_death_callback = on_death_callback
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_drops/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_drops/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/list/final_loot
	if(on_death_callback)
		final_loot = on_death_callback.Invoke(gibbed)
	else
		final_loot = loot

	for(var/thing_to_spawn in final_loot)
		if(loot[thing_to_spawn]) //If this is an assoc list, use the value of that to get the right amount
			for(var/index in 1 to loot[thing_to_spawn])
				new thing_to_spawn(target.drop_location())
		else
			new thing_to_spawn(target.drop_location())
