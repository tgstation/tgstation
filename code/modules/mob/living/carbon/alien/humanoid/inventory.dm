//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj, dropped = 1)
	if(!W) return 0
	var/success = 0
	if (W == wear_suit)
		wear_suit = null
		success = 1
		update_inv_wear_suit(0)
	else if (W == head)
		head = null
		success = 1
		update_inv_head(0)
	else if (W == r_store)
		r_store = null
		success = 1
		update_inv_pockets(0)
	else if (W == l_store)
		l_store = null
		success = 1
		update_inv_pockets(0)
	else if (W == r_hand)
		r_hand = null
		success = 1
		update_inv_r_hand(0)
	else if (W == l_hand)
		l_hand = null
		success = 1
		update_inv_l_hand(0)
	else
		return 0

	if(success)
		if (client)
			client.screen -= W
		if(dropped)
			W.loc = loc
			W.dropped(src)
		if(W)
			W.layer = initial(W.layer)
	return 1

/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/W = get_active_hand()
	if(W)
		if(!istype(W))	return
		switch(slot_id)
//			if("o_clothing")
//			if("head")
			if(slot_l_store)
				if(l_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W,0)
				l_store = W
				update_inv_pockets()
			if(slot_r_store)
				if(r_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W,0)
				r_store = W
				update_inv_pockets()
	else
		switch(slot_id)
			if(slot_wear_suit)
				if(wear_suit)	wear_suit.attack_alien(src)
			if(slot_head)
				if(head)		head.attack_alien(src)
			if(slot_l_store)
				if(l_store)		l_store.attack_alien(src)
			if(slot_r_store)
				if(r_store)		r_store.attack_alien(src)