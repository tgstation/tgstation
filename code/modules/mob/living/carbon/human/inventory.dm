//TODO: maybe these could be defines?
/mob/living/carbon/human
	var/const/slot_back			= 1
	var/const/slot_wear_mask	= 2
	var/const/slot_handcuffed	= 3
	var/const/slot_l_hand		= 4
	var/const/slot_r_hand		= 5
	var/const/slot_belt			= 6
	var/const/slot_wear_id		= 7
	var/const/slot_ears			= 8
	var/const/slot_glasses		= 9
	var/const/slot_gloves		= 10
	var/const/slot_head			= 11
	var/const/slot_shoes		= 12
	var/const/slot_wear_suit	= 13
	var/const/slot_w_uniform	= 14
	var/const/slot_l_store		= 15
	var/const/slot_r_store		= 16
	var/const/slot_s_store		= 17
	var/const/slot_in_backpack	= 18

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
	return null

//puts the item "W" into an appropriate slot in a human's inventory
/mob/living/carbon/human/proc/equip_to_appropriate_slot(obj/item/W)
	if(!W)				return
	if(!ishuman(src))	return

	if(W.slot_flags & SLOT_BACK)
		if(!back)
			if( get_active_hand() == W )
				u_equip(W)
			back = W
			update_inv_back()
			return

	if(W.slot_flags & SLOT_ID)
		if(!wear_id && w_uniform)
			if( get_active_hand() == W )
				u_equip(W)
			wear_id = W
			update_inv_wear_id()
			return

	if(W.slot_flags & SLOT_ICLOTHING)
		if(!w_uniform)
			if( get_active_hand() == W )
				u_equip(W)
			w_uniform = W
			update_inv_w_uniform()
			return

	if(W.slot_flags & SLOT_OCLOTHING)
		if(!wear_suit)
			if( get_active_hand() == W )
				u_equip(W)
			wear_suit = W
			update_inv_wear_suit()
			return

	if(W.slot_flags & SLOT_MASK)
		if(!wear_mask)
			if( get_active_hand() == W )
				u_equip(W)
			wear_mask = W
			update_inv_wear_mask()
			return

	if(W.slot_flags & SLOT_HEAD)
		if(!head)
			if( get_active_hand() == W )
				u_equip(W)
			head = W
			update_inv_head()
			return

	if(W.slot_flags & SLOT_FEET)
		if(!shoes)
			if( get_active_hand() == W )
				u_equip(W)
			shoes = W
			update_inv_shoes()
			return

	if(W.slot_flags & SLOT_GLOVES)
		if(!gloves)
			if( get_active_hand() == W )
				u_equip(W)
			gloves = W
			update_inv_gloves()
			return

	if(W.slot_flags & SLOT_EARS)
		if(!ears)
			if( get_active_hand() == W )
				u_equip(W)
			ears = W
			update_inv_ears()
			return

	if(W.slot_flags & SLOT_EYES)
		if(!glasses)
			if( get_active_hand() == W )
				u_equip(W)
			glasses = W
			update_inv_glasses()
			return

	if(W.slot_flags & SLOT_BELT)
		if(!belt && w_uniform)
			if( get_active_hand() == W )
				u_equip(W)
			belt = W
			update_inv_belt()
			return

	//Suit storage
	var/confirm
	if (wear_suit)
		if(wear_suit.allowed)
			if (istype(W, /obj/item/device/pda) || istype(W, /obj/item/weapon/pen))
				confirm = 1
			if (is_type_in_list(W, wear_suit.allowed))
				confirm = 1
		if(confirm)
			u_equip(W)
			s_store = W
			update_inv_s_store()
			return

	//Pockets
	if ( !( W.slot_flags & SLOT_DENYPOCKET ) )
		if(!l_store)
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				l_store = W
				update_inv_pockets()
				return
		if(!r_store)
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				r_store = W
				update_inv_pockets()
				return


/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, del_on_fail = 1) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	if((slot == l_store || slot == r_store || slot == belt || slot == wear_id) && !src.w_uniform)
		del(W)
		return
	if(slot == s_store && !src.wear_suit)
		del(W)
		return
	switch(slot)
		if(slot_back)
			if(!src.back)
				src.back = W
				update_inv_back(0)
				equipped = 1
		if(slot_wear_mask)
			if(!src.wear_mask)
				src.wear_mask = W
				update_inv_wear_mask(0)
				equipped = 1
		if(slot_handcuffed)
			if(!src.handcuffed)
				src.handcuffed = W
				update_inv_handcuffed(0)
				equipped = 1
		if(slot_l_hand)
			if(!src.l_hand)
				src.l_hand = W
				update_inv_l_hand(0)
				equipped = 1
		if(slot_r_hand)
			if(!src.r_hand)
				src.r_hand = W
				update_inv_r_hand(0)
				equipped = 1
		if(slot_belt)
			if(!src.belt)
				src.belt = W
				update_inv_belt(0)
				equipped = 1
		if(slot_wear_id)
			if(!src.wear_id)
				src.wear_id = W
				update_inv_wear_id(0)
				equipped = 1
		if(slot_ears)
			if(!src.ears)
				src.ears = W
				update_inv_ears(0)
				equipped = 1
		if(slot_glasses)
			if(!src.glasses)
				src.glasses = W
				update_inv_glasses(0)
				equipped = 1
		if(slot_gloves)
			if(!src.gloves)
				src.gloves = W
				update_inv_gloves(0)
				equipped = 1
		if(slot_head)
			if(!src.head)
				src.head = W
				update_inv_head(0)
				equipped = 1
		if(slot_shoes)
			if(!src.shoes)
				src.shoes = W
				update_inv_shoes(0)
				equipped = 1
		if(slot_wear_suit)
			if(!src.wear_suit)
				src.wear_suit = W
				update_inv_wear_suit(0)
				equipped = 1
		if(slot_w_uniform)
			if(!src.w_uniform)
				src.w_uniform = W
				update_inv_w_uniform(0)
				equipped = 1
		if(slot_l_store)
			if(!src.l_store)
				src.l_store = W
				update_inv_pockets(0)
				equipped = 1
		if(slot_r_store)
			if(!src.r_store)
				src.r_store = W
				update_inv_pockets(0)
				equipped = 1
		if(slot_s_store)
			if(!src.s_store)
				src.s_store = W
				update_inv_s_store(0)
				equipped = 1
		if(slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1

	if(equipped)
		W.layer = 20
	else
		if (del_on_fail)
			del(W)
	return equipped


/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if(!W)	return 0
	if (W == wear_suit)
		W = s_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		wear_suit = null
		update_inv_wear_suit(0)
	else if (W == w_uniform)
		W = r_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = l_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = wear_id
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = belt
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		w_uniform = null
		update_inv_w_uniform(0)
	else if (W == gloves)
		gloves = null
		update_inv_gloves(0)
	else if (W == glasses)
		glasses = null
		update_inv_glasses(0)
	else if (W == head)
		head = null
		if(W.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
		update_inv_head(0)
	else if (W == ears)
		ears = null
		update_inv_ears(0)
	else if (W == shoes)
		shoes = null
		update_inv_shoes(0)
	else if (W == belt)
		belt = null
		update_inv_belt(0)
	else if (W == wear_mask)
		wear_mask = null
		if(W.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask(0)
	else if (W == wear_id)
		wear_id = null
		update_inv_wear_id(0)
	else if (W == r_store)
		r_store = null
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		update_inv_pockets()
	else if (W == s_store)
		s_store = null
		update_inv_s_store(0)
	else if (W == back)
		back = null
		update_inv_back(0)
	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed(0)
	else if (W == r_hand)
		r_hand = null
		update_inv_r_hand(0)
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand(0)
	else
		return 0
	return 1


/obj/effect/equip_e/human/process()		//TODO: Rewrite this steaming pile... ~Carn
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					//SN src = null
					del(src)
					return
/*			if("headset")
				if (!( target.w_radio ))
					//SN src = null
					del(src)
					return */
			if("l_hand")
				if (!( target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( target.back ))
					//SN src = null
					del(src)
					return
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		if(isrobot(source) && place != "handcuff")
			del(src)
			return
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", source, item, target), 1)
	else
		var/message=null
		switch(place)
			if("syringe")
				message = text("\red <B>[] is trying to inject []!</B>", source, target)
			if("pill")
				message = text("\red <B>[] is trying to force [] to swallow []!</B>", source, target, item)
			if("fuel")
				message = text("\red [source] is trying to force [target] to eat the [item:content]!")
			if("drink")
				message = text("\red <B>[] is trying to force [] to swallow a gulp of []!</B>", source, target, item)
			if("dnainjector")
				message = text("\red <B>[] is trying to inject [] with the []!</B>", source, target, item)
			if("mask")
				if(istype(target.wear_mask, /obj/item/clothing)&&!target.wear_mask:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_mask, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
/*			if("headset")
				message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", source, target.w_radio, target) */
			if("l_hand")
				message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", source, target.l_hand, target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", source, target.r_hand, target)
			if("gloves")
				if(istype(target.gloves, /obj/item/clothing)&&!target.gloves:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.gloves, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", source, target.gloves, target)
			if("eyes")
				if(istype(target.glasses, /obj/item/clothing)&&!target.glasses:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.glasses, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", source, target.glasses, target)
			if("ears")
				if(istype(target.ears, /obj/item/clothing)&&!target.ears:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.ears, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", source, target.ears, target)
			if("head")
				if(istype(target.head, /obj/item/clothing)&&!target.head:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.head, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", source, target.head, target)
			if("shoes")
				if(istype(target.shoes, /obj/item/clothing)&&!target.shoes:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.shoes, target)
				else
					message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", source, target.shoes, target)
			if("belt")
				message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", source, target.belt, target)
			if("suit")
				if(istype(target.wear_suit, /obj/item/clothing)&&!target.wear_suit:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
			if("back")
				message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", source, target.back, target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
			if("uniform")
				if(istype(target.w_uniform, /obj/item/clothing)&&!target.w_uniform:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
			if("s_store")
				message = text("\red <B>[] is trying to take off \a [] from []'s suit!</B>", source, target.s_store, target)
			if("pockets")
				for(var/obj/item/weapon/mousetrap/MT in  list(target.l_store, target.r_store))
					if(MT.armed)
						for(var/mob/O in viewers(target, null))
							if(O == source)
								O.show_message(text("\red <B>You reach into the [target]'s pockets, but there was a live mousetrap in there!</B>"), 1)
							else
								O.show_message(text("\red <B>[source] reaches into [target]'s pockets and sets off a hidden mousetrap!</B>"), 1)
						target.u_equip(MT)
						if (target.client)
							target.client.screen -= MT
						MT.loc = source.loc
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
						MT.layer = OBJ_LAYER
						return
				message = text("\red <B>[] is trying to empty []'s pockets!!</B>", source, target)
			if("CPR")
				if (target.cpr_time >= world.time + 3)
					//SN src = null
					del(src)
					return
				message = text("\red <B>[] is trying perform CPR on []!</B>", source, target)
			if("id")
				message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", source, target.wear_id, target)
			if("internal")
				if (target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 40 )
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
!canremove refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/effect/equip_e/human/done()	//TODO: And rewrite this :< ~Carn
	if(!source || !target)						return
	if(source.loc != s_loc)						return
	if(target.loc != t_loc)						return
	if(LinkBlocked(s_loc,t_loc))				return
	if(item && source.equipped() != item)		return
	if ((source.restrained() || source.stat))	return
	switch(place)
		if("mask")
			if (target.wear_mask)
				if(istype(target.wear_mask, /obj/item/clothing)&& !target.wear_mask:canremove)
					return
				var/obj/item/clothing/W = target.wear_mask
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					if (W)
						W.layer = initial(W.layer)
						W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/mask))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_mask = item
					item.loc = target
					target.update_inv_wear_mask(0)
/*		if("headset")
			if (target.w_radio)
				var/obj/item/W = target.w_radio
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_radio = item
					item.loc = target*/
		if("gloves")
			if (target.gloves)
				if(istype(target.gloves, /obj/item/clothing)&& !target.gloves:canremove)
					return
				var/obj/item/clothing/W = target.gloves
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/gloves))
					source.drop_item()
					loc = target
					item.layer = 20
					target.gloves = item
					item.loc = target
					target.update_inv_gloves(0)
		if("eyes")
			if (target.glasses)
				if(istype(target.glasses, /obj/item/clothing)&& !target.glasses:canremove)
					return
				var/obj/item/W = target.glasses
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/glasses))
					source.drop_item()
					loc = target
					item.layer = 20
					target.glasses = item
					item.loc = target
					target.update_inv_glasses(0)
		if("belt")
			if (target.belt)
				var/obj/item/W = target.belt
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if ((istype(item, /obj) && (item.slot_flags & SLOT_BELT) && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.belt = item
					item.loc = target
					target.update_inv_belt(0)
		if("s_store")
			if (target.s_store)
				var/obj/item/W = target.s_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj) && target.wear_suit)
					var/confirm
					for(var/i=1, i<=target.wear_suit.allowed.len, i++)
		//				world << "[target.wear_suit.allowed[i]] and [W.type]"
						if (findtext("[item.type]","[target.wear_suit.allowed[i]]") || istype(item, /obj/item/device/pda) || istype(item, /obj/item/weapon/pen))
							confirm = 1
							break
					if (!confirm) return
					else
						source.drop_item()
						loc = target
						item.layer = 20
						target.s_store = item
						item.loc = target
						target.update_inv_s_store(0)
		if("head")
			if (target.head)
				if(istype(target.head, /obj/item/clothing)&& !target.head:canremove)
					return
				var/obj/item/W = target.head
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/head))
					source.drop_item()
					loc = target
					item.layer = 20
					target.head = item
					item.loc = target
					target.update_inv_head(0)
		if("ears")
			if (target.ears)
				if(istype(target.ears, /obj/item/clothing)&& !target.ears:canremove)
					return
				var/obj/item/W = target.ears
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if( istype(item, /obj/item/clothing/ears) || istype(item, /obj/item/device/radio/headset) )
					source.drop_item()
					loc = target
					item.layer = 20
					target.ears = item
					item.loc = target
					target.update_inv_ears(0)
		if("shoes")
			if (target.shoes)
				if(istype(target.shoes, /obj/item/clothing)&& !target.shoes:canremove)
					return
				var/obj/item/W = target.shoes
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/shoes))
					source.drop_item()
					loc = target
					item.layer = 20
					target.shoes = item
					item.loc = target
					target.update_inv_shoes(0)
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.l_hand)
				var/obj/item/W = target.l_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
					W.dropped(target)			//dropped sometimes deletes src so put it last
			else
				if(istype(item, /obj/item))
					source.drop_item()
					if(item)
						loc = target
						item.layer = 20
						target.l_hand = item
						item.loc = target
						item.add_fingerprint(target)
						target.update_inv_l_hand(0)
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.r_hand)
				var/obj/item/W = target.r_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
					W.dropped(target)			//dropped sometimes deletes src so put it last
			else
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					if (item)
						item.layer = 20
						target.r_hand = item
						item.loc = target
						item.add_fingerprint(target)
						target.update_inv_r_hand(0)
		if("uniform")
			if (target.w_uniform)
				if(istype(target.w_uniform, /obj/item/clothing)&& !target.w_uniform:canremove)
					return
				var/obj/item/W = target.w_uniform
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
				W = target.l_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.r_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.wear_id
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/clothing/under))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_uniform = item
					item.loc = target
					target.update_inv_w_uniform(0)
		if("suit")
			if(target.wear_suit)
				var/obj/item/W = target.wear_suit
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/suit))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_suit = item
					item.loc = target
					target.update_inv_wear_suit(0)
		if("id")
			if (target.wear_id)
				var/obj/item/W = target.wear_id
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (((istype(item, /obj/item/weapon/card/id)||istype(item, /obj/item/device/pda)) && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_id = item
					item.loc = target
					target.update_inv_wear_id(0)
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if ((istype(item, /obj/item) && (item.slot_flags & SLOT_BACK) ))
					source.drop_item()
					loc = target
					item.layer = 20
					target.back = item
					item.loc = target
					target.update_inv_back(0)
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/weapon/handcuffs))
					target.drop_from_slot(target.r_hand)
					target.drop_from_slot(target.l_hand)
					source.drop_item()
					target.handcuffed = item
					item.loc = target
					target.update_inv_handcuffed(0)
		if("CPR")
			if (target.cpr_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			if ((target.health >= -99.0 && target.health < 0))
				target.cpr_time = world.time
				var/suff = min(target.getOxyLoss(), 7)
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] performs CPR on []!", source, target), 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat every 7 seconds AT LEAST."
/*		if("fuel")
			var/obj/item/weapon/fuel/S = item
			if (!( istype(S, /obj/item/weapon/fuel) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.content
			for(var/mob/O in viewers(source, null))
				O.show_message(text("\red [source] forced [target] to eat the [a]!"), 1)
			S.injest(target)	*/
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(item)
				item.add_fingerprint(source)
				item:inject(target, null)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					//SN src = null
					del(src)
					return
				if (S.s_time >= world.time + 30)
					//SN src = null
					del(src)
					return
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] injects [] with the DNA Injector!", source, target), 1)
		if("pockets")
			if (target.l_store)
				var/obj/item/W = target.l_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
			if (target.r_store)
				var/obj/item/W = target.r_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
					W.add_fingerprint(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message(text("[] is now running on internals.", target), 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
	//update overlays
//	source.update_icons()
	if(target)
		target.update_icons()

	spawn(0)	// <-- not sure why this spawn is here
		if(source)
			if(source.machine == target)
				target.show_inv(source)
	del(src)
	return

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if(emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	else
		if( !istype(W, /obj/item) )		return

	switch(text)
		if("mask")
			if(wear_mask)
				if(emptyHand)
					wear_mask.DblClick()
				return
			if (!( W.slot_flags & SLOT_MASK ))
				return
			u_equip(W)
			wear_mask = W
			if(wear_mask && (wear_mask.flags & BLOCKHAIR))
				update_hair(0)	//rebuild hair
			W.equipped(src, text)
			update_inv_wear_mask()
		if("back")
			if (back)
				if (emptyHand)
					back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_BACK ))
				return
			if(istype(W,/obj/item/weapon/twohanded) && W:wielded)
				usr << "<span class='warning'>Unwield the [initial(W.name)] first!</span>"
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
			update_inv_back()
/*		if("headset")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_OCLOTHING ))
				return
			if ((FAT in src.mutations) && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
			update_inv_wear_suit()
		if("gloves")
			if (gloves)
				if (emptyHand)
					gloves.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_GLOVES ))
				return
			u_equip(W)
			gloves = W
			W.equipped(src, text)
			update_inv_gloves()
		if("shoes")
			if (shoes)
				if (emptyHand)
					shoes.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_FEET ))
				return
			u_equip(W)
			shoes = W
			W.equipped(src, text)
			update_inv_shoes()
		if("belt")
			if (belt)
				if (emptyHand)
					belt.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_BELT ))
				return
			u_equip(W)
			belt = W
			W.equipped(src, text)
			update_inv_belt()
		if("eyes")
			if (glasses)
				if (emptyHand)
					glasses.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_EYES ))
				return
			u_equip(W)
			glasses = W
			W.equipped(src, text)
			update_inv_glasses()
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_HEAD ))
				return
			u_equip(W)
			head = W
			if(head.flags & BLOCKHAIR)
				//rebuild hair
				update_hair(0)
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, text)
			update_inv_head()
		if("ears")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_EARS ))
				return
			u_equip(W)
			ears = W
			W.equipped(src, text)
			update_inv_ears()
		if("i_clothing")
			if (w_uniform)
				if (emptyHand)
					w_uniform.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_ICLOTHING ))
				return
			if ((FAT in src.mutations) && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			w_uniform = W
			W.equipped(src, text)
			update_inv_w_uniform()
		if("id")
			if (wear_id)
				if (emptyHand)
					wear_id.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_ID ))
				return
			u_equip(W)
			wear_id = W
			W.equipped(src, text)
			update_inv_wear_id()
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item))
				return
			if ( ( W.slot_flags & SLOT_DENYPOCKET ) )
				return
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				l_store = W
				update_inv_pockets()
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item))
				return
			if ( ( W.slot_flags & SLOT_DENYPOCKET ) )
				return
			if ( W.w_class <= 2 || ( W.slot_flags & SLOT_POCKET ) )
				u_equip(W)
				r_store = W
				update_inv_pockets()
		if("suit storage")
			if (s_store)
				if (emptyHand)
					s_store.DblClick()
				return
			var/confirm
			if (wear_suit)
				if(!wear_suit.allowed)
					usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return
				if (istype(W, /obj/item/device/pda) || istype(W, /obj/item/weapon/pen))
					confirm = 1
				if (is_type_in_list(W, wear_suit.allowed))
					confirm = 1
			if (!confirm) return
			else
				u_equip(W)
				s_store = W
				update_inv_s_store()
	return