
///////////////////
//DRONE INVENTORY//
///////////////////
//Drone inventory
//Drone hands




/mob/living/simple_animal/drone/activate_hand(selhand)

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode()


/mob/living/simple_animal/drone/swap_hand()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return

	hand = !hand
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()


/mob/living/simple_animal/drone/unEquip(obj/item/I, force)
	if(..(I,force))
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
		if(slot_drone_storage)
			if(internal_storage)
				return 0
			return 1
	..()


/mob/living/simple_animal/drone/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if(slot_drone_storage)
			return internal_storage
	..()


/mob/living/simple_animal/drone/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null
	update_inv_hands()

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = 20

	switch(slot)
		if(slot_head)
			head = I
			update_inv_head()
		if(slot_drone_storage)
			internal_storage = I
			update_inv_internal_storage()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return


/mob/living/simple_animal/drone/stripPanelUnequip(obj/item/what, mob/who, where)
	..(what, who, where, 1)


/mob/living/simple_animal/drone/stripPanelEquip(obj/item/what, mob/who, where)
	..(what, who, where, 1)

/mob/living/simple_animal/drone/getBackSlot()
	return slot_drone_storage

/mob/living/simple_animal/drone/getBeltSlot()
	return slot_drone_storage
