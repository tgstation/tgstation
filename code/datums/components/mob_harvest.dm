/**
 * Harvesting component. Useful if you want to be able to harvest items from living mobs.
 *
 * Used currently on sheep.
 */
/datum/component/mob_harvest
	///item used to harvest
	var/obj/item/harvest_tool = /obj/item/razor
	///item used to reduce wait between items
	var/obj/item/fed_item = /obj/item/food/grown/grass
	///typepath of the item you want to harvest
	var/produced_item_typepath = /obj/item/food/bait
	///stand-in name for the item
	var/produced_item_desc = "funny worm"
	///how much is ready to harvest
	var/amount_ready = 1
	///max amount that can be stored between harvests
	var/max_ready = 1
	///time between item creation
	var/item_generation_wait = 10 SECONDS
	///tracked time
	var/item_generation_time = 0
	///time to reduce when fed
	var/item_reduction_time = 2 SECONDS
	///how long it takes to harvest from the mob
	var/item_harvest_time = 5 SECONDS
	///typepath of harvest sound
	var/item_harvest_sound = 'sound/items/tools/welder2.ogg'

//harvest_type, produced_item_typepath and speedup_type are typepaths, not reference
/datum/component/mob_harvest/Initialize(harvest_tool, fed_item, produced_item_typepath, produced_item_desc, max_ready, item_generation_wait, item_reduction_time, item_harvest_time, item_harvest_sound)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.harvest_tool = harvest_tool
	src.fed_item = fed_item
	src.produced_item_typepath = produced_item_typepath
	src.produced_item_desc = produced_item_desc
	src.max_ready = max_ready
	src.item_generation_wait = item_generation_wait
	src.item_reduction_time = item_reduction_time
	src.item_harvest_time = item_harvest_time
	item_generation_time = item_generation_wait
	START_PROCESSING(SSobj, src)

/datum/component/mob_harvest/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/mob_harvest/vv_edit_var(var_name, var_value)
	var/amount_changed
	if(var_name == NAMEOF(src, max_ready))
		var_value = max(0, var_value) //no negatives allowed
		if(amount_ready != min(amount_ready, var_value)) //check to max sure max_ready isn't lower than the amount ready.
			amount_ready = var_value
			amount_changed = TRUE
	if(var_name == NAMEOF(src, amount_ready) && var_value != amount_ready)
		amount_changed = TRUE
	. = ..()
	if(amount_changed && !iscarbon(parent))
		var/mob/living/living_parent = parent
		living_parent.update_appearance(UPDATE_ICON_STATE)

/datum/component/mob_harvest/process(seconds_per_tick)
	///only track time if we aren't dead and have room for more items
	var/mob/living/harvest_mob = parent
	if(harvest_mob.stat == DEAD || amount_ready >= max_ready)
		return

	item_generation_time -= seconds_per_tick
	if(item_generation_time > 0)
		return

	item_generation_time = item_generation_wait
	amount_ready++
	if(iscarbon(parent))
		return

	var/mob/living/living_parent = parent
	living_parent.update_appearance(UPDATE_ICON_STATE)

/datum/component/mob_harvest/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

	// Only do update_icon_state business on non-carbon mobs
	if(!iscarbon(parent))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))

		var/mob/living/living_parent = parent
		living_parent.update_appearance(UPDATE_ICON_STATE)

/datum/component/mob_harvest/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_UPDATE_ICON_STATE))

///signal called on parent being examined
/datum/component/mob_harvest/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(amount_ready < 1)
		examine_list += span_notice("[parent] seems like they could use a bit more time.")
	if(amount_ready > 1)
		examine_list += span_notice("[parent] looks like they can be harvested about [amount_ready] times.")
	if(amount_ready == 1)
		examine_list += span_notice("[parent] looks ready to be harvested.")

///signal called on parent being attacked with an item
/datum/component/mob_harvest/proc/on_attackby(datum/source, obj/item/used_item, mob/user)
	SIGNAL_HANDLER

	if(istype(used_item, harvest_tool))
		INVOKE_ASYNC(src, PROC_REF(harvest_item), user)
		return COMPONENT_NO_AFTERATTACK

	if(istype(used_item, fed_item))
		remove_wait_time(user)
		qdel(used_item)
		return COMPONENT_NO_AFTERATTACK

/// Signal proc for [COMSIG_ATOM_UPDATE_ICON_STATE]
/datum/component/mob_harvest/proc/on_update_icon_state(datum/source)
	SIGNAL_HANDLER

	// If this is being used on a carbon or human, don't update any icon states, just leave it
	if(iscarbon(parent))
		return

	var/mob/living/living_parent = parent
	if(living_parent.stat == DEAD)
		return

	living_parent.icon_state = "[living_parent.base_icon_state || initial(living_parent.icon_state)][amount_ready < 1 ? "_harvested" : ""]"

/**
 * Proc called from attacking the component parent with the correct item, reduces wait time between items
 *
 * Arguments:
 * * mob/user - who is trying to do this
 */
/datum/component/mob_harvest/proc/remove_wait_time(mob/user)
	if(amount_ready >= max_ready)
		to_chat(user, span_warning("[parent] looks too full to keep feeding!"))
		return
	item_generation_time -= item_reduction_time
	to_chat(user, span_notice("You feed [parent]."))
	return

/**
 * Proc called from attacking the component parent with the correct item, handles creating the item
 *
 * Arguments:
 * * mob/user - who is trying to do this
 */
/datum/component/mob_harvest/proc/harvest_item(mob/user)
	if(amount_ready < 1)
		to_chat(user, span_warning("[parent] doesn't seem to have enough [produced_item_desc] to harvest."))
		return
	to_chat(user, span_notice("You start to harvest [produced_item_desc] from [parent]..."))
	if(do_after(user, item_harvest_time, target = parent))
		playsound(parent, item_harvest_sound, 20, TRUE)
		to_chat(user, span_notice("You harvest some [produced_item_desc] from [parent]."))
		amount_ready--
		if(!iscarbon(parent))
			var/mob/living/living_parent = parent
			living_parent.update_appearance(UPDATE_ICON_STATE)
		new produced_item_typepath(get_turf(parent))
		return
