//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/I, slot, redraw_mob = 1)
	if(!slot)	return
	if(!istype(I))	return

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null

	switch(slot)
		if(slot_back)
			back = I
			I.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			wear_mask = I
			I.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			handcuffed = I
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			legcuffed = I
			I.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			l_hand = I
			I.equipped(src, slot)
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			r_hand = I
			I.equipped(src, slot)
			update_inv_r_hand(redraw_mob)
		if(slot_in_backpack)
			if(I == get_active_hand())
				u_equip(I)
			I.loc = back
			return
		else
			usr << "\red You are trying to equip this item to an unsupported inventory slot. Report this to a coder."
			return

	I.loc = src
	I.equipped(src, slot)
	I.layer = 20