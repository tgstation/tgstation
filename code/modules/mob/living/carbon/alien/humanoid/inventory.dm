/mob/living/carbon/alien/humanoid/unEquip(obj/item/I)
	. = ..()
	if(!. || !I)
		return

	if(I == r_store)
		r_store = null
		update_inv_pockets(0)
	else if(I == l_store)
		l_store = null
		update_inv_pockets(0)


//yaaaaaaay snowflakes
/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/I = get_active_hand()
	if(!I)	return 0
	if(I.w_class > 3)	return 0

	if(I == l_hand)
		l_hand = null
	else if(I == r_hand)
		r_hand = null

	switch(slot_id)
		if(slot_l_store)
			if(l_store)
				return 0
			l_store = I
			update_inv_pockets()
		if(slot_r_store)
			if(r_store)
				return 0
			r_store = I
			update_inv_pockets()

	I.loc = src
	I.equipped(src, slot_id)
	I.layer = 20

	return 1