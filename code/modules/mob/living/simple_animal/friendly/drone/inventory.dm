
///////////////////
//DRONE INVENTORY//
///////////////////
//Drone inventory
//Drone hands




/mob/living/simple_animal/drone/activate_hand(var/selhand)

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
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


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
		if("drone_storage_slot")
			if(internal_storage)
				return 0
			return 1
	..()


/mob/living/simple_animal/drone/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_head)
			return head
		if("drone_storage_slot")
			return internal_storage
	..()


/mob/living/simple_animal/drone/equip_to_slot(obj/item/I, slot)
	if(!slot)	return
	if(!istype(I))	return

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
		if("drone_storage_slot")
			internal_storage = I
			update_inv_internal_storage()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"
			return


/mob/living/simple_animal/drone/stripPanelUnequip(obj/item/what, mob/who, where)
	..(what, who, where, 1)


/mob/living/simple_animal/drone/stripPanelEquip(obj/item/what, mob/who, where)
	..(what, who, where, 1)