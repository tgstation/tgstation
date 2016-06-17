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

/mob/living/carbon/u_equip(obj/item/W as obj, dropped = 1)
	var/success = 0
	if(!W)	return 0
	else if (W == handcuffed)
		if(handcuffed.on_remove(src)) //If this returns 1, then the unquipping action was interrupted
			return 0
		handcuffed = null
		success = 1
		update_inv_handcuffed()
	else if (W == legcuffed)
		legcuffed = null
		success = 1
		update_inv_legcuffed()
	else
		..()
	if(success)
		if (W)
			if (client)
				client.screen -= W
			W.forceMove(loc)
			W.unequipped()
			if(dropped)
				W.dropped(src)
			if(W)
				W.layer = initial(W.layer)

	return

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
