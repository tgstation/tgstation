/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
	return null

/mob/living/carbon/get_all_slots()
	return list(handcuffed,
				legcuffed,
				back,
				wear_mask) + held_items

//everything on the mob that is not in its pockets, hands belt, etc.
/mob/living/carbon/get_clothing_items()
	var/list/equipped = ..()
	equipped -= list(handcuffed,
					legcuffed,
					back)
	return equipped