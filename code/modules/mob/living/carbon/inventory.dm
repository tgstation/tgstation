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


/mob/living/carbon/unEquip(obj/item/I) //THIS PROC DID NOT CALL ..() AND THAT COST ME AN ENTIRE DAY OF DEBUGGING.
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == head)
		head = null
		if(I.flags & BLOCKHAIR)
			update_hair(0)
		update_inv_head(0)
	else if(I == back)
		back = null
		update_inv_back(0)
	else if(I == wear_mask)
		if(istype(src, /mob/living/carbon/human)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		update_inv_wear_mask(0)
	else if(I == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed(0)
	else if(I == legcuffed)
		legcuffed = null
		update_inv_legcuffed(0)

