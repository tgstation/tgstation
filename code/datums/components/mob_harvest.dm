/**
 * Harvesting component. Useful if you want to be able to harvest items from living mobs.
 *
 * Used currently on sheep.
 */
/datum/component/mob_harvest
	///abstract item for managing the drops
	var/obj/item/mob_harvest/mob_harvest
	///item used to harvest
	var/obj/item/harvest_tool = /obj/item/razor
	///item used to reduce wait between items
	var/obj/item/fed_item = /obj/item/food/grown/grass

//harvest_type, produced_item_typepath and speedup_type are typepaths, not reference
/datum/component/mob_harvest/Initialize(harvest_type = /obj/item/mob_harvest, speedup_type = fed_item)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	mob_harvest = new harvest_type(null, parent)

/datum/component/mob_harvest/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/datum/component/mob_harvest/UnregisterFromParent()
	QDEL_NULL(mob_harvest)
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY))

///signal called on parent being examined
/datum/component/mob_harvest/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(mob_harvest.amount_ready < 1)
		examine_list += span_notice("[parent] seems like they could use a bit more time.")
	if(mob_harvest.amount_ready > 1)
		examine_list += span_notice("[parent] looks like they can be harvested about [mob_harvest.amount_ready] times.")
	if(mob_harvest.amount_ready == 1)
		examine_list += span_notice("[parent] looks ready to be harvested.")

///signal called on parent being attacked with an item
/datum/component/mob_harvest/proc/on_attackby(datum/source, obj/item/used_item, mob/user)
	SIGNAL_HANDLER

	if(istype(used_item, harvest_tool))
		mob_harvest.harvest_item(user)
	if(istype(used_item, fed_item))
		mob_harvest.remove_wait_time(user)
		qdel(used_item)
	return COMPONENT_NO_AFTERATTACK


/**
 * # Harvester item
 *
 * Abstract item that is held in nullspace and manages the time it takes to get a new item and creating said item
 */
/obj/item/mob_harvest
	name = "magical mob-powered item generator"
	desc = "put inside mob to magically make items. you probably shouldn't be able to see this"
	///typepath of the item you want to harvest
	var/produced_item_typepath = /obj/item/food/bait
	///stand-in name for the item
	var/produced_item_desc = "funny worm"
	///how much is ready to harvest
	var/amount_ready = 1
	///max amount that can be stored between harvests
	var/max_ready = 1
	///mob that has the component
	var/mob/living/harvest_mob
	///time between item creation
	var/item_generation_wait = 10 SECONDS
	///tracked time
	var/item_generation_time = 0
	///time to reduce when fed
	var/item_reduction_time = 2 SECONDS

/obj/item/mob_harvest/Initialize(mapload, harvest_mob)
	src.harvest_mob = harvest_mob
	item_generation_time = item_generation_wait
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/mob_harvest/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	harvest_mob = null

/obj/item/mob_harvest/process(delta_time)
	///only track time if we aren't dead and have room for more items
	if(harvest_mob.stat != DEAD && amount_ready < max_ready)
		item_generation_time -= delta_time
		if(item_generation_time <= 0)
			item_generation_time = item_generation_wait
			amount_ready++

/**
 * Proc called from attacking the component parent with the correct item, reduces wait time between items
 *
 * Arguments:
 * * mob/user - who is trying to do this
 */
/obj/item/mob_harvest/proc/remove_wait_time(mob/user)
	if(amount_ready >= max_ready)
		to_chat(user, span_warning("[harvest_mob] looks too full to keep feeding!"))
		return		
	item_generation_time -= item_reduction_time
	to_chat(user, span_notice("You feed [harvest_mob]."))
	return

/**
 * Proc called from attacking the component parent with the correct item, handles creating the item
 *
 * Arguments:
 * * mob/user - who is trying to do this
 */
/obj/item/mob_harvest/proc/harvest_item(mob/user)
	if(amount_ready < 1)
		to_chat(user, span_warning("[harvest_mob] doesn't seem ready yet to harvest from."))
		return
	to_chat(user, span_notice("You harvest some [produced_item_typepath] from [harvest_mob]."))
	amount_ready--
	new produced_item_typepath(get_turf(harvest_mob))
	return


/**
 * # Sheep's mob_harvest item
 *
 * Used by sheep to generate wool. Has an extra check for amount ready to determine if sheep looks sheared or not.
 */
/obj/item/mob_harvest/sheep
	name = "fluffy wool generator"
	desc = "creates wool through sheer will and determination"
	produced_item_typepath = /obj/item/stack/sheet/cotton/wool
	produced_item_desc = "soft wool"
	item_generation_wait = 5 MINUTES
	item_reduction_time = 30 SECONDS
	var/woolless = FALSE

/obj/item/mob_harvest/sheep/process(delta_time)
	..()
	if(amount_ready > 0 && woolless)
		woolless = FALSE
		harvest_mob.icon_state = "sheep"
		harvest_mob.update_icon()

/obj/item/mob_harvest/sheep/harvest_item(mob/user)
	if(amount_ready < 1)
		to_chat(user, span_warning("[harvest_mob] doesn't seem like they have enough [produced_item_desc] to get anything of value."))
		return
	to_chat(user, span_notice("You start to shear [harvest_mob].."))
	if(do_after(user, 30, target = src) && amount_ready >= 1)
		to_chat(user, span_notice("You shear some [produced_item_desc] from [harvest_mob]."))
		amount_ready--
		new produced_item_typepath(get_turf(harvest_mob))
		if(amount_ready < 1)
			woolless = TRUE
			harvest_mob.icon_state = "sheep_harvested"
			harvest_mob.update_icon()
		return

