// Drone inventory procs

/mob/living/basic/drone/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(item_dropping == head)
			head = null
			update_worn_head()
		if(item_dropping == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return TRUE
	return FALSE


/mob/living/basic/drone/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(slot & ITEM_SLOT_STORAGE)
		return isnull(internal_storage)
	if(slot & ITEM_SLOT_HEAD)
		if(head)
			return FALSE
		if(!(item.slot_flags & ITEM_SLOT_HEAD) && !(item.slot_flags & ITEM_SLOT_MASK))
			return FALSE
		return TRUE
	return ..()


/mob/living/basic/drone/get_item_by_slot(slot_id)
	if(slot_id & ITEM_SLOT_HEAD)
		return head
	if(slot_id & ITEM_SLOT_STORAGE)
		return internal_storage
	return ..()

/mob/living/basic/drone/get_slot_by_item(obj/item/looking_for)
	if(internal_storage == looking_for)
		return ITEM_SLOT_STORAGE
	if(head == looking_for)
		return ITEM_SLOT_HEAD
	return ..()

/mob/living/basic/drone/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
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

	hud_used?.update_inventory_slot(slot)
	equipping.forceMove(src) //This has to come before has_equipped is called.
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)

	if(slot & ITEM_SLOT_STORAGE)
		internal_storage = equipping
		update_inv_internal_storage()
	else switch(slot)
		if(ITEM_SLOT_HEAD)
			head = equipping
			update_worn_head()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	//Call back for item being equipped to drone
	has_equipped(equipping, slot)
