//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
		update_inv_wear_suit(0)
	else if (W == head)
		head = null
		update_inv_head(0)
	else if (W == r_store)
		r_store = null
		update_inv_pockets(0)
	else if (W == l_store)
		l_store = null
		update_inv_pockets(0)
	else if (W == r_hand)
		r_hand = null
		update_inv_r_hand(0)
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand(0)

/mob/living/carbon/alien/humanoid/db_click(text, t1)
	var/obj/item/W = get_active_hand()
	if(W)
		if(!istype(W))	return
		switch(text)
//			if("o_clothing")
//			if("head")
			if("storage1")
				if(l_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W)
				l_store = W
				update_inv_pockets()
			if("storage2")
				if(r_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W)
				r_store = W
				update_inv_pockets()
	else
		switch(text)
			if("o_clothing")
				if(wear_suit)	wear_suit.attack_alien(src)
			if("head")
				if(head)		head.attack_alien(src)
			if("storage1")
				if(l_store)		l_store.attack_alien(src)
			if("storage2")
				if(r_store)		r_store.attack_alien(src)