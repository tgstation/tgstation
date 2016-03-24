/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_head)
			return head
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return
	if(!istype(I))
		return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null

	I.screen_loc = null // will get moved if inventory is visible
	I.loc = src
	I.equipped(src, slot)
	I.layer = 20

	switch(slot)
		if(slot_back)
			back = I
			update_inv_back()
		if(slot_wear_mask)
			wear_mask = I
			wear_mask_update(I, toggle_off = 0)
		if(slot_head)
			head = I
			head_update(I)
		if(slot_handcuffed)
			handcuffed = I
			update_handcuffed()
		if(slot_legcuffed)
			legcuffed = I
			update_inv_legcuffed()
		if(slot_l_hand)
			l_hand = I
			update_inv_l_hand()
		if(slot_r_hand)
			r_hand = I
			update_inv_r_hand()
		if(slot_in_backpack)
			if(I == get_active_hand())
				unEquip(I)
			I.loc = back
		else
			return 1


/mob/living/carbon/unEquip(obj/item/I)
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == head)
		head = null
		head_update(I)
	else if(I == back)
		back = null
		update_inv_back()
	else if(I == wear_mask)
		wear_mask = null
		wear_mask_update(I, toggle_off = 1)
	else if(I == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		update_inv_legcuffed()

//handle stuff to update when a mob equips/unequips a mask.
/mob/living/proc/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	if(C.tint || initial(C.tint))
		update_tint()
	update_inv_wear_mask()

//handle stuff to update when a mob equips/unequips a headgear.
/mob/living/carbon/proc/head_update(obj/item/I, forced)
	if(istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if(C.tint || initial(C.tint))
			update_tint()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()
