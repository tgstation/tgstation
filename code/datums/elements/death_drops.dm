/**
 * ## death drops element!
 *
 * bespoke element that spawns loot when a mob is killed
 */
/datum/element/death_drops
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///what items the target drops when killed
	var/list/loot

/datum/element/death_drops/Attach(datum/target, list/loot)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!loot)
		stack_trace("death drops element added to [target] with NO LOOT")
	if(!src.loot)
		src.loot = loot.Copy()
	RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

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
