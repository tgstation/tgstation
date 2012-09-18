//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand


//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(var/obj/item/W)
	if(lying)			return 0
	if(!istype(W))		return 0
	if(!l_hand)
		W.loc = src		//TODO: move to equipped?
		l_hand = W
		W.layer = 20	//TODO: move to equipped?
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,slot_l_hand)
		if(client)	client.screen |= W
		update_inv_l_hand()
		return 1
	return 0

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(var/obj/item/W)
	if(lying)			return 0
	if(!istype(W))		return 0
	if(!r_hand)
		W.loc = src
		r_hand = W
		W.layer = 20
//		r_hand.screen_loc = ui_rhand
		W.equipped(src,slot_r_hand)
		if(client)	client.screen |= W
		update_inv_r_hand()
		return 1
	return 0

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(var/obj/item/W)
	if(hand)	return put_in_l_hand(W)
	else		return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(var/obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(var/obj/item/W)
	if(!W)		return 0
	if(put_in_active_hand(W))			return 1
	else if(put_in_inactive_hand(W))	return 1
	else
		W.loc = get_turf(src)
		W.layer = initial(W.layer)
		W.dropped()
		return 0



/mob/proc/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		return drop_item()
	return 0


/mob/proc/drop_from_inventory(var/obj/item/W)
	if(W)
		if(client)	client.screen -= W
		u_equip(W)
		W.layer = initial(W.layer)
		W.loc = loc

		var/turf/T = get_turf(loc)
		if(isturf(T))
			T.Entered(W)

		W.dropped(src)
		update_icons()
		return 1
	return 0


//Drops the item in our left hand
/mob/proc/drop_l_hand(var/atom/Target)
	if(l_hand)
		if(client)	client.screen -= l_hand
		l_hand.layer = initial(l_hand.layer)

		if(Target)	l_hand.loc = Target.loc
		else		l_hand.loc = loc

		var/turf/T = get_turf(loc)
		if(isturf(T))
			T.Entered(l_hand)

		l_hand.dropped(src)
		l_hand = null
		update_inv_l_hand()
		return 1
	return 0

//Drops the item in our right hand
/mob/proc/drop_r_hand(var/atom/Target)
	if(r_hand)
		if(client)	client.screen -= r_hand
		r_hand.layer = initial(r_hand.layer)

		if(Target)	r_hand.loc = Target.loc
		else		r_hand.loc = loc

		var/turf/T = get_turf(Target)
		if(istype(T))
			T.Entered(r_hand)

		r_hand.dropped(src)
		r_hand = null
		update_inv_r_hand()
		return 1
	return 0

//Drops the item in our active hand.
/mob/proc/drop_item(var/atom/Target)
	if(hand)	return drop_l_hand(Target)
	else		return drop_r_hand(Target)









//TODO: phase out this proc
/mob/proc/before_take_item(var/obj/item/W)	//TODO: what is this?
	W.loc = null
	W.layer = initial(W.layer)
	u_equip(W)
	update_icons()
	return


/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
		update_inv_r_hand(0)
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand(0)
	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed(0)
	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else if (W == back)
		back = null
		update_inv_back(0)
	else if (W == wear_mask)
		wear_mask = null
		update_inv_wear_mask(0)
	return


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1


//Outdated but still in use apparently. This should at least be a human proc.
/mob/proc/get_equipped_items()
	var/list/items = new/list()

	if(hasvar(src,"back")) if(src:back) items += src:back
	if(hasvar(src,"belt")) if(src:belt) items += src:belt
	if(hasvar(src,"ears")) if(src:ears) items += src:ears
	if(hasvar(src,"glasses")) if(src:glasses) items += src:glasses
	if(hasvar(src,"gloves")) if(src:gloves) items += src:gloves
	if(hasvar(src,"head")) if(src:head) items += src:head
	if(hasvar(src,"shoes")) if(src:shoes) items += src:shoes
	if(hasvar(src,"wear_id")) if(src:wear_id) items += src:wear_id
	if(hasvar(src,"wear_mask")) if(src:wear_mask) items += src:wear_mask
	if(hasvar(src,"wear_suit")) if(src:wear_suit) items += src:wear_suit
//	if(hasvar(src,"w_radio")) if(src:w_radio) items += src:w_radio  commenting this out since headsets go on your ears now PLEASE DON'T BE MAD KEELIN
	if(hasvar(src,"w_uniform")) if(src:w_uniform) items += src:w_uniform

	//if(hasvar(src,"l_hand")) if(src:l_hand) items += src:l_hand
	//if(hasvar(src,"r_hand")) if(src:r_hand) items += src:r_hand

	return items

/** BS12's proc to get the item in the active hand. Couldn't find the /tg/ equivalent. **/
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
		return