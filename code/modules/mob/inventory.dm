/mob/proc/get_active_hand()
	if (hand)
		return l_hand
	else
		return r_hand

/mob/proc/get_inactive_hand()
	if (!hand)
		return l_hand
	else
		return r_hand

/mob/proc/put_in_hand(var/obj/item/I)
	if(!I) return
	I.loc = src
	if (hand)
		l_hand = I
		update_inv_l_hand()
	else
		r_hand = I
		update_inv_r_hand()
	I.layer = 20

/mob/proc/put_in_hands(var/obj/item/I) //A suprisingly useful proc.  Allows a simple way to place an object in a mob's hands, or, if they are full, on the ground below them.
	if(!r_hand)
		I.loc = src
		r_hand = I
		update_inv_r_hand()
		I.layer = 20
	else if(!l_hand)
		I.loc = src
		l_hand = I
		update_inv_l_hand()
		I.layer = 20
	else
		I.loc = get_turf(src)

/mob/proc/drop_item_v()
	if (stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in contents))
		return
	u_equip(item)
	if (client)
		client.screen -= item
	if (item)
		item.loc = loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(item)
	return

/mob/proc/drop_item(var/atom/target)
	var/obj/item/W = equipped()

	if (W)
		u_equip(W)
		update_icons()
		if (client)
			client.screen -= W
		if (W)
			W.layer = initial(W.layer)
			if(target)
				W.loc = target.loc
			else
				W.loc = loc
			W.dropped(src)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(W)
	return

/mob/proc/before_take_item(var/obj/item/item)
	item.loc = null
	item.layer = initial(item.layer)
	u_equip(item)
	//if (client)
	//	client.screen -= item
	update_icons()
	return

/mob/proc/put_in_inactive_hand(var/obj/item/I)
	I.loc = src
	if (!hand)
		l_hand = I
		update_inv_l_hand()
	else
		r_hand = I
		update_inv_r_hand()
	I.layer = 20


/mob/proc/equipped()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (hand)
			return l_hand
		else
			return r_hand




/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
	else if (W == back)
		back = null
		update_inv_back()
	else if (W == wear_mask)
		wear_mask = null
		update_inv_wear_mask()
	return


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1
