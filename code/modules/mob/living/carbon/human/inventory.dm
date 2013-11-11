/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			H << "<span class='notice'>You are not holding anything to equip.</span>"
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			H << "\red You are unable to equip that."


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/I, list/slots, del_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], del_on_fail = 0))
			return slot
	if(del_on_fail)
		del(I)
	return null


// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_belt)
			return belt
		if(slot_wear_id)
			return wear_id
		if(slot_ears)
			return ears
		if(slot_glasses)
			return glasses
		if(slot_gloves)
			return gloves
		if(slot_head)
			return head
		if(slot_shoes)
			return shoes
		if(slot_wear_suit)
			return wear_suit
		if(slot_w_uniform)
			return w_uniform
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_s_store)
			return s_store
	return null


/mob/living/carbon/human/u_equip(obj/item/I)
	if(!I)	return 0

	var/success = 0

	if(I == wear_suit)
		if(s_store)
			u_equip(s_store)
		if(I)
			success = 1
		wear_suit = null
		update_inv_wear_suit(0)
	else if(I == w_uniform)
		if(r_store)
			u_equip(r_store)
		if(l_store)
			u_equip(l_store)
		if(wear_id)
			u_equip(wear_id)
		if(belt)
			u_equip(belt)
		w_uniform = null
		success = 1
		update_inv_w_uniform(0)
	else if(I == gloves)
		gloves = null
		success = 1
		update_inv_gloves(0)
	else if(I == glasses)
		glasses = null
		success = 1
		update_inv_glasses(0)
	else if(I == head)
		head = null
		if(I.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
		success = 1
		update_inv_head(0)
	else if(I == ears)
		ears = null
		success = 1
		update_inv_ears(0)
	else if(I == shoes)
		shoes = null
		success = 1
		update_inv_shoes(0)
	else if(I == belt)
		belt = null
		success = 1
		update_inv_belt(0)
	else if(I == wear_mask)
		wear_mask = null
		success = 1
		if(I.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask(0)
	else if(I == wear_id)
		wear_id = null
		success = 1
		update_inv_wear_id(0)
	else if(I == r_store)
		r_store = null
		success = 1
		update_inv_pockets(0)
	else if(I == l_store)
		l_store = null
		success = 1
		update_inv_pockets(0)
	else if(I == s_store)
		s_store = null
		success = 1
		update_inv_s_store(0)
	else if(I == back)
		back = null
		success = 1
		update_inv_back(0)
	else if(I == handcuffed)
		handcuffed = null
		success = 1
		update_inv_handcuffed(0)
	else if(I == legcuffed)
		legcuffed = null
		success = 1
		update_inv_legcuffed(0)
	else if(I == r_hand)
		r_hand = null
		success = 1
		update_inv_r_hand(0)
	else if(I == l_hand)
		l_hand = null
		success = 1
		update_inv_l_hand(0)
	else
		return 0

	if(success)
		if(I)
			if(client)
				client.screen -= I
			I.loc = loc
			I.dropped(src)
			if(I)
				I.layer = initial(I.layer)

	update_action_buttons()
	return 1


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, redraw_mob = 1)
	if(!slot)	return
	if(!istype(I))	return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null
	I.screen_loc = null // will get moved if inventory is visible

	switch(slot)
		if(slot_back)
			back = I
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			wear_mask = I
			if(wear_mask.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			handcuffed = I
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			legcuffed = I
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			l_hand = I
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			r_hand = I
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			belt = I
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			wear_id = I
			update_inv_wear_id(redraw_mob)
		if(slot_ears)
			ears = I
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			glasses = I
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			gloves = I
			update_inv_gloves(redraw_mob)
		if(slot_head)
			head = I
			if(head.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			update_inv_head(redraw_mob)
		if(slot_shoes)
			shoes = I
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			wear_suit = I
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			w_uniform = I
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			l_store = I
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			r_store = I
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			s_store = I
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(get_active_hand() == I)
				u_equip(I)
			I.loc = back
			return
		else
			src << "\red You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"
			return

	I.loc = src
	I.equipped(src, slot)
	I.layer = 20