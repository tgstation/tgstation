
///////////////////
//DRONE INVENTORY//
///////////////////
//Drone inventory
//Drone hands


/mob/living/simple_animal/drone/doUnEquip(obj/item/I, force)
	if(..())
		update_inv_hands()
		if(I == head)
			head = null
			update_inv_head()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0


/mob/living/simple_animal/drone/can_equip(obj/item/I, slot)
	switch(slot)
		if(slot_head)
			if(head)
				return 0
			if(!((I.slot_flags & SLOT_HEAD) || (I.slot_flags & SLOT_MASK)))
				return 0
			return 1
		if(slot_generic_dextrous_storage)
			if(internal_storage)
				return 0
			return 1
	..()


/mob/living/simple_animal/drone/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if(slot_generic_dextrous_storage)
			return internal_storage
	return ..()


/mob/living/simple_animal/drone/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
	update_inv_hands()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(slot_head)
			head = I
			update_inv_head()
		if(slot_generic_dextrous_storage)
			internal_storage = I
			update_inv_internal_storage()
		else
			to_chat(src, "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")
			return

	//Call back for item being equipped to drone
	I.equipped(src, slot)

/mob/living/simple_animal/drone/getBackSlot()
	return slot_generic_dextrous_storage

/mob/living/simple_animal/drone/getBeltSlot()
	return slot_generic_dextrous_storage
