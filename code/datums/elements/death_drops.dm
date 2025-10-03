/**
 * ## death drops element!
 *
 * bespoke element that spawn can spawn one or multiple objects when a mob is killed
 */
/datum/element/death_drops
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// What items the target drops when killed
	var/list/loot
	/// Should the items not be dropped when gibbed?
	var/no_gib_drops

/datum/element/death_drops/Attach(datum/target, list/loot, no_gib_drops = FALSE)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!loot)
		stack_trace("[type] added to [target] with NO LOOT.")
	src.loot = loot
	src.no_gib_drops = no_gib_drops
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/death_drops/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

///signal called by the stat of the target changing
/datum/element/death_drops/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	if (no_gib_drops && gibbed)
		return

	var/list/spawn_loot = null
	if (islist(loot))
		spawn_loot = loot.Copy()
	else
		spawn_loot = list(loot)

	var/atom/loot_loc = target.drop_location()
	if (SEND_SIGNAL(target, COMSIG_LIVING_DROP_LOOT, spawn_loot, gibbed) & COMPONENT_NO_LOOT_DROP)
		return

	for(var/thing_to_spawn in spawn_loot)
		for(var/i in 1 to (spawn_loot[thing_to_spawn] || 1))
			create_loot(thing_to_spawn, loot_loc, target, gibbed, spread_px = spawn_loot.len * 3)

/// Handles creating the loots
/datum/element/death_drops/proc/create_loot(typepath, atom/loot_loc, mob/living/dead, gibbed, spread_px = 4)
	if(ispath(typepath, /obj/effect/mob_spawn/corpse))
		handle_corpse(typepath, loot_loc, dead, gibbed)
		return

	var/drop = new typepath(loot_loc)
	if(isitem(drop) && spread_px)
		var/obj/item/dropped_item = drop
		var/clamped_px = clamp(spread_px, 0, 16)
		dropped_item.pixel_x = rand(-clamped_px, clamped_px)
		dropped_item.pixel_y = rand(-clamped_px, clamped_px)

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
