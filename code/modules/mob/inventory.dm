//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand

// Get the organ of the active hand
/mob/proc/get_active_hand_organ()
	if(!istype(src, /mob/living/carbon)) return
	if (hasorgans(src))
		var/datum/organ/external/temp = src:organs_by_name["r_hand"]
		if (hand)
			temp = src:organs_by_name["l_hand"]
		return temp

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand

// Because there's several different places it's stored.
/mob/proc/get_multitool(var/if_active=0)
	return null

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(var/obj/item/W)
	if(!put_in_hand_check(W, hand))
		return 0

	if(!l_hand)
		W.loc = src		//TODO: move to equipped?
		l_hand = W
		W.layer = 20	//TODO: move to equipped?
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,slot_l_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_l_hand()
		return 1
	return 0

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(var/obj/item/W)
	if(!put_in_hand_check(W, hand))
		return 0

	if(!r_hand)
		W.loc = src
		r_hand = W
		W.layer = 20
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
//		r_hand.screen_loc = ui_rhand
		W.equipped(src,slot_r_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_r_hand()
		return 1
	return 0

/mob/proc/put_in_hand_check(var/obj/item/W)
	if(lying) //&& !(W.flags & ABSTRACT))
		return 0

	if(!isitem(W))
		return 0

	if(W.flags & MUSTTWOHAND)
		if(!W.wield(src, 1))
			to_chat(src, "You need both hands to pick up \the [W].")
			return 0

	return 1

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
	if(put_in_active_hand(W))
		update_inv_l_hand()
		update_inv_r_hand()
		return 1
	else if(put_in_inactive_hand(W))
		update_inv_l_hand()
		update_inv_r_hand()
		return 1
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
		u_equip(W,1)
		if(!W) return 1 // self destroying objects (tk, grabs)
		W.layer = initial(W.layer)
		W.loc = loc

		var/turf/T = get_turf(loc)
		if(isturf(T))
			T.Entered(W)

		//W.dropped(src)
		//update_icons() // Redundant as u_equip will handle updating the specific overlay
		return 1
	return 0

// Drops all and only equipped items, including items in hand
/mob/proc/drop_all()
	for (var/obj/item/I in get_all_slots())
		drop_from_inventory(I)


//Drops the item in our hand - you can specify an item and a location to drop to
/mob/proc/drop_item(var/obj/item/to_drop, var/atom/Target)

	if(!candrop) //can't drop items while etheral
		return 0

	if(!to_drop) //if we're not told to drop something specific
		to_drop = get_active_hand() //drop what we're currently holding

	if(!istype(to_drop)) //still nothing to drop?
		return 0 //bail

	if(!Target)
		Target = src.loc

	remove_from_mob(to_drop) //clean out any refs

	if(!to_drop)
		return 0

	to_drop.forceMove(Target) //calls the Entered procs

	to_drop.dropped(src)

	if(to_drop && to_drop.loc)
		return 1
	return 0

/mob/proc/drop_hands(var/atom/Target) //drops both items
	drop_item(get_active_hand(), Target)
	drop_item(get_inactive_hand(), Target)

//TODO: phase out this proc
/mob/proc/before_take_item(var/obj/item/W)	//TODO: what is this?
	W.loc = null
	W.layer = initial(W.layer)
	u_equip(W,0)
	update_icons()
	return


/mob/proc/u_equip(var/obj/item/W as obj, dropped = 1)
	if(!W) return 0
	var/success = 0
	if (W == r_hand)
		r_hand = null
		success = 1
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		success = 1
		update_inv_l_hand()
	else if (W == back)
		back = null
		success = 1
		update_inv_back()
	else if (W == wear_mask)
		wear_mask = null
		success = 1
		update_inv_wear_mask()
	else
		return 0

	if(success)
		if(client)
			client.screen -= W
		if(dropped)
			W.loc = loc
			W.dropped(src)
		if(W)
			W.layer = initial(W.layer)
	return 1


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	src.u_equip(O,1)
	if (src.client)
		src.client.screen -= O
	if(!O) return
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1

/mob/proc/get_all_slots()
	return list(wear_mask, back, l_hand, r_hand)

//everything on the mob that it isn't holding
/mob/proc/get_equipped_items()
	var/list/equipped = get_all_slots()
	equipped -= list(get_active_hand(), get_inactive_hand())
	return equipped

//everything on the mob that is not in its pockets, hands and belt.
/mob/proc/get_clothing_items()
	var/list/equipped = get_all_slots()
	equipped -= list(get_active_hand(), get_inactive_hand())
	return equipped

/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, act_on_fail = EQUIP_FAILACTION_DELETE) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(slot_belt)
			if(!src.belt && src.w_uniform)
				src.belt = W
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id && src.w_uniform)
				src.wear_id = W
				equipped = 1
		if(slot_ears)
			if(!src.ears)
				src.ears = W
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(slot_l_store)
			if(!src.l_store && src.w_uniform)
				src.l_store = W
				equipped = 1
		if(slot_r_store)
			if(!src.r_store && src.w_uniform)
				src.r_store = W
				equipped = 1
		if(slot_s_store)
			if(!src.s_store && src.wear_suit)
				src.s_store = W
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1

	if(equipped)
		W.layer = 20
		if(src.back && W.loc != src.back)
			W.loc = src
	else
		switch(act_on_fail)
			if(EQUIP_FAILACTION_DELETE)
				del(W)
			if(EQUIP_FAILACTION_DROP)
				W.loc=get_turf(src) // I think.
	return equipped

/mob/proc/get_id_card()
	for(var/obj/item/I in src.get_all_slots())
		. = I.GetID()
		if(.)
			break

