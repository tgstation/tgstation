/mob/living/carbon/alien/humanoid/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return

	if(src.is_holding_item(W))
		src.u_equip(W)

	switch(slot)
		if(slot_head)
			src.head = W
			update_inv_head(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			update_inv_wear_suit(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			update_inv_pockets(redraw_mob)
		else
			to_chat(usr, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = 20
	W.equipped(src, slot)
	W.forceMove(src)
	if(client) client.screen |= W

// Return the item currently in the slot ID
/mob/living/carbon/alien/humanoid/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_wear_suit)
			return wear_suit
		if(slot_head)
			return head
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
	return null

//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj, dropped = 1)
	if(!W) return 0
	var/success = 0
	var/index = is_holding_item(W)
	if(index)
		held_items[index] = null
		success = 1
		update_inv_hand(index)
	else if (W == wear_suit)
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
	else
		return 0

	if(success)
		if (client)
			client.screen -= W
		W.forceMove(loc)
		W.unequipped()
		if(dropped)
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
				if(W.w_class > W_CLASS_MEDIUM)
					return
				u_equip(W,0)
				l_store = W
				update_inv_pockets()
			if(slot_r_store)
				if(r_store)
					return
				if(W.w_class > W_CLASS_MEDIUM)
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
