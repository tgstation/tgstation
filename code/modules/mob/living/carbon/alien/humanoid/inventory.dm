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
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)

//if emptyhand then wear the suit, no bedsheet clothes for the alien

		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
//			else
//				update_inv_wear_suit()
			return
/*			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
*/
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
			else if (( istype(W, /obj/effect/alien/head) ))	//TODO: figure out wtf this is about ~Carn
				u_equip(W)
				head = W
				update_inv_head()
			return
/*			if (!( istype(W, /obj/item/clothing/head) ))
				return
			u_equip(W)
			head = W
			W.equipped(src, text)
*/
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			u_equip(W)
			l_store = W
			update_inv_pockets()
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			u_equip(W)
			r_store = W
			update_inv_pockets()
	return