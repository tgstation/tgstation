/mob/living/basic/flock/agent/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(item_dropping == head)
			head = null
			update_worn_head()
		if(item_dropping == internal_storage)
			if(eat_mode)
				stop_eating_item(internal_storage)
			internal_storage = null
			if(!silent)
				playsound(get_turf(src), 'troutstation/sound/items/handling/flock_agent_storage_rustle.ogg', 40, TRUE, -5)
			update_inv_internal_storage()
		return TRUE
	return FALSE

/mob/living/basic/flock/agent/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	switch(slot)
		if(ITEM_SLOT_HEAD)
			if(head)
				return FALSE
			if(!((item.slot_flags & ITEM_SLOT_HEAD) || (item.slot_flags & ITEM_SLOT_MASK)))
				return FALSE
			return TRUE
		if(ITEM_SLOT_DEX_STORAGE)
			if(internal_storage)
				return FALSE
			if(item.w_class > WEIGHT_CLASS_NORMAL)
				if(!disable_warning)
					to_chat(src, span_warning("It's bigger than your internal storage!"))
				return FALSE
			return TRUE
	..()

/mob/living/basic/flock/agent/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_DEX_STORAGE)
			return internal_storage
	return ..()

/mob/living/basic/flock/agent/get_slot_by_item(obj/item/looking_for)
	if(internal_storage == looking_for)
		return ITEM_SLOT_DEX_STORAGE
	if(head == looking_for)
		return ITEM_SLOT_HEAD
	return ..()

/mob/living/basic/flock/agent/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!slot)
		return
	if(!istype(equipping))
		return

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null
	update_held_items()

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null // will get moved if inventory is visible
	equipping.forceMove(src)
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)

	switch(slot)
		if(ITEM_SLOT_HEAD)
			head = equipping
			update_worn_head()
		if(ITEM_SLOT_DEX_STORAGE)
			internal_storage = equipping
			if(!is_creating)
				playsound(get_turf(src), 'troutstation/sound/items/handling/flock_agent_storage_rustle.ogg', 40, TRUE, -5)
				if(internal_storage.drop_sound)
					playsound(get_turf(src), internal_storage.drop_sound, 30, TRUE, -7)
				src.visible_message(span_notice("[src] pops open a slot in [src.p_their()] back and puts [internal_storage] in it."),
					span_notice("You pop open your internal storage and put [internal_storage] in it."),
					blind_message = span_hear("You hear something popping open and something being placed inside it."))
				if(eat_mode)
					start_eating_item(equipping)
			update_inv_internal_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	has_equipped(equipping, slot)

/mob/living/basic/flock/agent/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/basic/flock/agent/proc/toggle_eat_mode()
	if(stat)
		return
	if(eat_mode)
		eat_mode_off()
		SEND_SOUND(src, sound('troutstation/sound/effects/flock/flock_interface_off.ogg', volume = 25))
	else
		eat_mode_on()
		SEND_SOUND(src, sound('troutstation/sound/effects/flock/flock_interface_on.ogg', volume = 25))

/mob/living/basic/flock/agent/proc/eat_mode_on()
	if(internal_storage && istype(internal_storage, /obj/item/flock_creation))
		to_chat(src, span_warning("No, you're using that space to make something."))
		return
	eat_mode = TRUE
	if(hud_used)
		var/datum/hud/flock_agent/flock_hud = hud_used
		if(flock_hud)
			flock_hud.eat.icon_state = "eat_on"
			flock_hud.internal.update_appearance()
	if(internal_storage)
		start_eating_item(internal_storage)

/mob/living/basic/flock/agent/proc/eat_mode_off()
	eat_mode = FALSE
	if(hud_used)
		var/datum/hud/flock_agent/flock_hud = hud_used
		if(flock_hud)
			flock_hud.eat.icon_state = "eat"
			flock_hud.internal.update_appearance()
	if(internal_storage)
		stop_eating_item(internal_storage)
