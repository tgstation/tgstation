/**
 * ## death drops element!
 *
 * bespoke element that spawns loot when a mob is killed
 */
/datum/element/death_drops
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	///what items the target drops when killed
	var/list/loot

/datum/element/death_drops/Attach(datum/target, list/loot)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!loot)
		stack_trace("death drops element added to [target] with NO LOOT")
	src.loot = loot
	RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)

/datum/element/death_drops/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_drops/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	generate_items_inside(loot, target.drop_location())
