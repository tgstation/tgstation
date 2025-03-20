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
	var/atom/loot_loc = target.drop_location()
	for(var/thing_to_spawn in loot)
		for(var/i in 1 to (loot[thing_to_spawn] || 1))
			create_loot(thing_to_spawn, loot_loc, target, gibbed)

/// Handles creating the loots
/datum/element/death_drops/proc/create_loot(typepath, atom/loot_loc, mob/living/dead, gibbed)
	if(ispath(typepath, /obj/effect/mob_spawn/corpse))
		handle_corpse(typepath, loot_loc, dead, gibbed)
		return

	new typepath(loot_loc)

/// Handles snowflake case of mob corpses
/datum/element/death_drops/proc/handle_corpse(typepath, atom/loot_loc, mob/living/dead, gibbed)
	var/obj/effect/mob_spawn/corpse/spawner = new typepath(loot_loc, TRUE)
	var/mob/living/body = spawner.create()
	// done before the gib check so the bodyparts will be damaged
	body.setBruteLoss(dead.getBruteLoss())
	body.setFireLoss(dead.getFireLoss())
	// if gibbed, dispose of the body
	if(gibbed)
		body.gib(DROP_ALL_REMAINS)
		return
	// otherwise continue with the rest of the damage types
	body.setToxLoss(dead.getToxLoss())
	body.setOxyLoss(dead.getOxyLoss())
