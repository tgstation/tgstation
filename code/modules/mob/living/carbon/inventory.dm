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
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

//We need to override put_in_l/r_hand to check if said hands even exist in the first place.
//After that we can just call the super. |- Ricotez
/mob/living/carbon/put_in_l_hand(var/obj/item/W)
	if(organsystem)
		var/datum/organ/limb/limbdata = getorgan("l_arm")
		if(!limbdata.exists())
			return 0
	return ..()

/mob/living/carbon/put_in_r_hand(var/obj/item/W)
	if(organsystem)
		var/datum/organ/limb/limbdata = getorgan("r_arm")
		if(!limbdata.exists())
			return 0
	return ..()