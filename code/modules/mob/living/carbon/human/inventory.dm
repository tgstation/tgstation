/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			to_chat(H, "<span class='notice'>You are not holding anything to equip.</span>")
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			to_chat(H, "<span class='warning'>You are unable to equip that.</span>")

/mob/living/carbon/human/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
//ordered body items by which would appear on top
		l_hand,
		r_hand,
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		l_store,
		r_store,
		w_uniform)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
//also head ordered
		head,
		wear_mask,
		glasses,
		ears
		)

//everything on the mob that is not in its pockets, hands and belt.
/mob/living/carbon/human/get_clothing_items(var/list/filter)
	if(!filter || !istype(filter))
		filter = get_all_slots()
	filter -= list(back,
				handcuffed,
				legcuffed,
				belt,
				wear_id,
				l_hand,
				r_hand,
				l_store,
				r_store,
				s_store)
	return filter

/mob/living/carbon/human/proc/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= slot_gloves
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= slot_w_uniform
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= slot_shoes

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= slot_wear_mask
		if(head.flags_inv & HIDEEYES)
			obscured |= slot_glasses
		if(head.flags_inv & HIDEEARS)
			obscured |= slot_ears

	if(obscured.len > 0)
		return obscured
	else
		return null

//The args for check_hidden_flags are the list of equipment, and then the flags
//The arg for get_clothing items is the list of equipment - this filters stuff like hands, pockets, suit_storage, etc
//get_head_slots and get_body_slots do exactly what you think they do
/mob/living/carbon/human/proc/check_hidden_head_flags(var/hidden_flags = 0)
	return check_hidden_flags(get_clothing_items(get_head_slots()), hidden_flags)

/mob/living/carbon/human/proc/check_hidden_body_flags(var/hidden_flags = 0)
	return check_hidden_flags(get_clothing_items(get_body_slots()), hidden_flags)

/mob/living/carbon/human/proc/check_hidden_flags(var/list/items, var/hidden_flags = 0)
	if(!items || !istype(items))
		items = get_clothing_items() //no argument returns all clothing
	for(var/obj/item/equipped in items)
		if(!equipped)
			continue
		if(equipped.flags_inv & hidden_flags)
			return 1

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, act_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], 0))
			return slot
	switch (act_on_fail)
		if(EQUIP_FAILACTION_DELETE)
			del(W)
		if(EQUIP_FAILACTION_DROP)
			W.loc=get_turf(src) // I think.
	return null

/mob/living/carbon/human/proc/is_on_ears(var/typepath)
	return istype(ears,typepath)

/mob/living/carbon/human/proc/is_in_hands(var/typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return 0

/mob/living/carbon/human/put_in_hand_check(obj/item/I, this_hand)
	if(!src.can_use_hand(this_hand))
		return 0

	return ..()

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
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
		if(slot_belt)
			return belt
		if(slot_wear_id)
			return wear_id
		if(slot_ears)
			return ears
		if(slot_glasses)
			return glasses
		if(slot_gloves)
			return gloves
		if(slot_head)
			return head
		if(slot_shoes)
			return shoes
		if(slot_wear_suit)
			return wear_suit
		if(slot_w_uniform)
			return w_uniform
		if(slot_l_store)
			return l_store
		if(slot_r_store)
			return r_store
		if(slot_s_store)
			return s_store
	return null

/mob/living/carbon/human/proc/has_organ(name)
	var/datum/organ/external/O = organs_by_name[name]

	return (O && !(O.status & ORGAN_DESTROYED) )

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_organ("chest")
		if(slot_wear_mask)
			return has_organ("head")
		if(slot_handcuffed)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_legcuffed)
			return has_organ("l_leg") && has_organ("r_leg")
		if(slot_l_hand)
			return has_organ("l_hand")
		if(slot_r_hand)
			return has_organ("r_hand")
		if(slot_belt)
			return has_organ("chest")
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return 1
		if(slot_ears)
			return has_organ("head")
		if(slot_glasses)
			return has_organ("head")
		if(slot_gloves)
			return has_organ("l_hand") && has_organ("r_hand")
		if(slot_head)
			return has_organ("head")
		if(slot_shoes)
			return has_organ("r_foot") && has_organ("l_foot")
		if(slot_wear_suit)
			return has_organ("chest")
		if(slot_w_uniform)
			return has_organ("chest")
		if(slot_l_store)
			return has_organ("chest")
		if(slot_r_store)
			return has_organ("chest")
		if(slot_s_store)
			return has_organ("chest")
		if(slot_in_backpack)
			return 1

/mob/living/carbon/human/u_equip(obj/item/W as obj, dropped = 1)
	if(!W)	return 0

	var/success

	if (W == wear_suit)
		if(s_store)
			u_equip(s_store, 1)
		success = 1
		wear_suit = null
		update_inv_wear_suit()
	else if (W == w_uniform)
		if (r_store)
			u_equip(r_store, 1)
		if (l_store)
			u_equip(l_store, 1)
		if (wear_id)
			u_equip(wear_id, 1)
		if (belt)
			u_equip(belt, 1)
		w_uniform = null
		success = 1
		update_inv_w_uniform()
	else if (W == gloves)
		gloves = null
		success = 1
		update_inv_gloves()
	else if (W == glasses)
		glasses = null
		success = 1
		update_inv_glasses()
	else if (W == head)
		head = null
		success = 1
		update_inv_head()
	else if(W == ears)
		ears = null
		success = 1
		update_inv_ears()
	else if (W == shoes)
		shoes = null
		success = 1
		update_inv_shoes()
	else if (W == belt)
		belt = null
		success = 1
		update_inv_belt()
	else if (W == wear_mask)
		wear_mask = null
		success = 1
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask()
	else if (W == wear_id)
		wear_id = null
		success = 1
		update_inv_wear_id()
	else if (W == r_store)
		r_store = null
		success = 1
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		success = 1
		update_inv_pockets()
	else if (W == s_store)
		s_store = null
		success = 1
		update_inv_s_store()
	else if (W == back)
		back = null
		success = 1
		update_inv_back()
	else if (W == handcuffed)
		handcuffed = null
		success = 1
		update_inv_handcuffed()
	else if (W == legcuffed)
		legcuffed = null
		success = 1
		update_inv_legcuffed()
	else if (W == r_hand)
		r_hand = null
		success = 1
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		success = 1
		update_inv_l_hand()
	else
		return 0

	if(success)
		update_hidden_item_icons(W)

	if(success)
		if (W)
			if (client)
				client.screen -= W
			W.loc = loc
			W.unequipped()
			if(dropped) W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
	update_action_buttons()
	return 1



//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return

	if(W == src.l_hand)
		src.l_hand = null
		update_inv_l_hand() //So items actually disappear from hands.
	else if(W == src.r_hand)
		src.r_hand = null
		update_inv_r_hand()

	switch(slot)
		if(slot_back)
			src.back = W
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			update_inv_wear_id(redraw_mob)
		if(slot_ears)
			ears = W
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			//if((head.flags & BLOCKHAIR) || (head.flags & BLOCKHEADHAIR)) //Makes people bald when switching to one with no Blocking flags
			//	update_hair(redraw_mob)	//rebuild hair
			update_hair(redraw_mob)
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.u_equip(W,0)
			W.loc = src.back
			return
		else
			to_chat(src, "<span class='warning'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")
			return

	update_hidden_item_icons(W)

	W.layer = 20
	W.equipped(src, slot)
	W.loc = src


/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null	//source location
	var/t_loc = null	//target location
	var/obj/item/item = null
	var/place = null
	var/pickpocket = null

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/human/Destroy()
	if(target)
		target.requests -= src
	..()

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/equip_e/monkey/Destroy()
	if(target)
		target.requests -= src
	..()

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		qdel(src)
	spawn(100)
		qdel(src)
	..()
	return


/obj/effect/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	else
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					qdel(src)
			if("l_hand")
				if (!( target.l_hand ))
					qdel(src)
			if("r_hand")
				if (!( target.r_hand ))
					qdel(src)
			if("suit")
				if (!( target.wear_suit ))
					qdel(src)
			if("uniform")
				if (!( target.w_uniform ))
					qdel(src)
			if("back")
				if (!( target.back ))
					qdel(src)
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
					qdel(src)
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					qdel(src)
			if("splints")
				var/count = 0
				for(var/organ in list("l_leg","r_leg","l_arm","r_arm"))
					var/datum/organ/external/o = target.organs_by_name[organ]
					if(o.status & ORGAN_SPLINTED)
						count = 1
						break
				if(count == 0)
					qdel(src)
					return



			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					qdel(src)

			if("internal1")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.belt, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					qdel(src)

			if("internal2")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.s_store, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					qdel(src)


	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		if(isrobot(source) && place != "handcuff")
			qdel(src)
		for(var/mob/O in viewers(target, null))
			O.show_message("<span class='danger'>[source] is trying to put \a [item] on [target]</span>", 1)
	else
		var/message=null
		switch(place)
			if("syringe")
				message = "<span class='danger'>[source] is trying to inject [target]!</span>"
			if("pill")
				message = "<span class='danger'>[source] is trying to force [target] to swallow [item]!</span>"
			if("drink")
				message = "<span class='danger'>[source] is trying to force [target] to swallow a gulp of [item]!</span>"
			if("dnainjector")
				message = "<span class='danger'>[source] is trying to inject [target] with the [item]!</span>"
			if("mask")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their mask removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) mask</font>")
				if(target.wear_mask && !target.wear_mask.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.wear_mask] from [target]'s head!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.wear_mask] from [target]'s head!</span>"
			if("l_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left hand item ([target.l_hand]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left hand item ([target.l_hand])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.l_hand] from [target]'s left hand!</span>"
			if("r_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right hand item ([target.r_hand]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right hand item ([target.r_hand])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.r_hand] from [target]'s right hand!</span>"
			if("gloves")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their gloves ([target.gloves]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) gloves ([target.gloves])</font>")
				if(target.gloves && !target.gloves.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.gloves] from [target]'s hands!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.gloves] from [target]'s hands!</span>"
			if("eyes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their eyewear ([target.glasses]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) eyewear ([target.glasses])</font>")
				if(target.glasses && !target.glasses.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.glasses] from [target]'s eyes!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.glasses] from [target]'s eyes!</span>"
			if("ears")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ear item ([target.ears]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ear item ([target.ears])</font>")
				if(target.ears && !target.ears.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.ears] from [target]'s ears!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.ears] from [target]'s ears!</span>"
			if("head")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their hat ([target.head]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) hat ([target.head])</font>")
				if(target.head && !target.head.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.head] from [target]'s head!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.head] from [target]'s head!</span>"
			if("shoes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their shoes ([target.shoes]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) shoes ([target.shoes])</font>")
				if(target.shoes && !target.shoes.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.shoes] from [target]'s feet!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.shoes] from [target]'s feet!</span>"
			if("belt")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their belt item ([target.belt]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) belt item ([target.belt])</font>")
				if(!pickpocket)
					message = "<span class='danger'>[source] is trying to take off the [target.belt] from [target]'s belt!</span>"
				else
					to_chat(source, "<span class='notice'>You try to take off the [target.belt] from [target]'s belt!</span>")
			if("suit")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit ([target.wear_suit]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit ([target.wear_suit])</font>")
				if(target.wear_suit && !target.wear_suit.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.wear_suit] from [target]'s body!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.wear_suit] from [target]'s body!</span>"
			if("back")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their back item ([target.back]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) back item ([target.back])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.back] from [target]'s back!</span>"
			if("handcuff")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unhandcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unhandcuff [target.name]'s ([target.ckey])</font>")
				message = "<span class='danger'>[source] is trying to unhandcuff [target]!</span>"
			if("legcuff")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unlegcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unlegcuff [target.name]'s ([target.ckey])</font>")
				message = "<span class='danger'>[source] is trying to unlegcuff [target]!</span>"
			if("uniform")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their uniform ([target.w_uniform]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) uniform ([target.w_uniform])</font>")
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						return
				if(target.w_uniform && !target.w_uniform.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.w_uniform] from [target]'s body!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.w_uniform] from [target]'s body!</span>"
			if("s_store")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit storage item ([target.s_store]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit storage item ([target.s_store])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.s_store] from [target]'s suit!</span>"
			if("pockets")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their pockets emptied by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to empty [target.name]'s ([target.ckey]) pockets</font>")
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						return
				message = "<span class='danger'>[source] is trying to empty [target]'s pockets.</span>"
			if("CPR")
				if (!target.cpr_time)
					qdel(src)
				target.cpr_time = 0
				message = "<span class='danger'>[source] is trying perform CPR on [target]!</span>"
			if("id")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ID ([target.wear_id]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ID ([target.wear_id])</font>")
				if(!pickpocket)
					message = "<span class='danger'>[source] is trying to take off [target.wear_id] from [target]'s uniform!</span>"
				else
					to_chat(source, "<span class='notice'>You try to take off [target.wear_id] from [target]'s uniform!</span>")
			if("internal")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
				if (target.internal)
					message = "<span class='danger'>[source] is trying to remove [target]'s internals</span>"
				else
					message = "<span class='danger'>[source] is trying to set on [target]'s internals.</span>"

			if("internal1")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
				if (target.internal)
					message = "<span class='danger'>[source] is trying to remove [target]'s internals</span>"
				else
					message = "<span class='danger'>[source] is trying to set on [target]'s internals.</span>"

			if("internal2")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
				if (target.internal)
					message = "<span class='danger'>[source] is trying to remove [target]'s internals</span>"
				else
					message = "<span class='danger'>[source] is trying to set on [target]'s internals.</span>"
			if("splints")
				message = text("<span class='danger'>[] is trying to remove []'s splints!</span>", source, target)

		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn(HUMAN_STRIP_DELAY)
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
	target.cpr_time = 1
	if(isanimal(source)) return //animals cannot strip people
	if(!source || !target) return		//Target or source no longer exist
	if(source.loc != s_loc) return		//source has moved
	if(target.loc != t_loc) return		//target has moved
	if(!source.Adjacent(target)) return	//Use a proxi!
	if(item && source.get_active_hand() != item) return	//Swapped hands / removed item from the active one
	if ((source.restrained() || source.stat)) return //Source restrained or unconscious / dead

	var/slot_to_process
	var/strip_item //this will tell us which item we will be stripping - if any.

	switch(place)	//here we go again...
		if("mask")
			slot_to_process = slot_wear_mask
			if (target.wear_mask && target.wear_mask.canremove)
				strip_item = target.wear_mask
		if("gloves")
			slot_to_process = slot_gloves
			if (target.gloves && target.gloves.canremove)
				strip_item = target.gloves
		if("eyes")
			slot_to_process = slot_glasses
			if (target.glasses)
				strip_item = target.glasses
		if("belt")
			slot_to_process = slot_belt
			if (target.belt)
				strip_item = target.belt
		if("s_store")
			slot_to_process = slot_s_store
			if (target.s_store)
				strip_item = target.s_store
		if("head")
			slot_to_process = slot_head
			if (target.head && target.head.canremove)
				strip_item = target.head
		if("ears")
			slot_to_process = slot_ears
			if (target.ears)
				strip_item = target.ears
		if("shoes")
			slot_to_process = slot_shoes
			if (target.shoes && target.shoes.canremove)
				strip_item = target.shoes
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				qdel(src)
			slot_to_process = slot_l_hand
			if (target.l_hand)
				strip_item = target.l_hand
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				qdel(src)
			slot_to_process = slot_r_hand
			if (target.r_hand)
				strip_item = target.r_hand
		if("uniform")
			slot_to_process = slot_w_uniform
			if(target.w_uniform && target.w_uniform.canremove)
				strip_item = target.w_uniform
		if("suit")
			slot_to_process = slot_wear_suit
			if (target.wear_suit && target.wear_suit.canremove)
				strip_item = target.wear_suit
		if("id")
			slot_to_process = slot_wear_id
			if (target.wear_id)
				strip_item = target.wear_id
		if("back")
			slot_to_process = slot_back
			if (target.back)
				strip_item = target.back
		if("handcuff")
			slot_to_process = slot_handcuffed
			if (target.handcuffed)
				strip_item = target.handcuffed
		if("legcuff")
			slot_to_process = slot_legcuffed
			if (target.legcuffed)
				strip_item = target.legcuffed
		if("splints")
			for(var/organ in list("l_leg","r_leg","l_arm","r_arm"))
				var/datum/organ/external/o = target.get_organ(organ)
				if (o && o.status & ORGAN_SPLINTED)
					var/obj/item/W = new /obj/item/stack/medical/splint(amount=1)
					o.status &= ~ORGAN_SPLINTED
					if (W)
						W.loc = target.loc
						W.layer = initial(W.layer)
						W.add_fingerprint(source)
		if("CPR")
			if ((target.health > config.health_threshold_dead && target.health < config.health_threshold_crit))
				var/suff = min(target.getOxyLoss(), 7)
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message("<span class='warning'>[source] performs CPR on [target]!</span>", 1)
				to_chat(target, "<span class='notice'><b>You feel a breath of fresh air enter your lungs. It feels good.</b></span>")
				to_chat(source, "<span class='warning'>Repeat at least every 7 seconds.</span>")
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(S)
				S.add_fingerprint(source)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					S.inuse = 0
					qdel(src)
				S.inject(target, source)
				if (S.s_time >= world.time + 30)
					S.inuse = 0
					qdel(src)
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message("<span class='warning'>[source] injects [target] with the DNA Injector!</span>", 1)
				S.inuse = 0
		if("pockets")
			slot_to_process = slot_l_store
			strip_item = target.l_store		//We'll do both
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
							M.show_message("[target] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"



		if("internal1")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt

					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message("[target] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"


		if("internal2")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store

					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message("[target] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"

	if(slot_to_process)
		if(strip_item) //Stripping an item from the mob

			var/obj/item/W = strip_item
			target.u_equip(W,1)
			if (target.client)
				target.client.screen -= W
			if (W)
				W.loc = target.loc
				W.layer = initial(W.layer)
				//W.dropped(target)
			W.stripped(target,source)
			W.add_fingerprint(source)
			if(slot_to_process == slot_l_store) //pockets! Needs to process the other one too. Snowflake code, wooo! It's not like anyone will rewrite this anytime soon. If I'm wrong then... CONGRATULATIONS! ;)
				if(target.r_store)
					target.u_equip(target.r_store,0) //At this stage l_store is already processed by the code above, we only need to process r_store.
		else
			if(item && target.has_organ_for_slot(slot_to_process)) //Placing an item on the mob
				if(item.mob_can_equip(target, slot_to_process, 0))
					source.u_equip(item,1)
					//if(item)
						//item.dropped(source)
					target.equip_to_slot_if_possible(item, slot_to_process, 0, 1, 1)
					source.update_icons()
					target.update_icons()

	if(source && target)
		if(source.machine == target)
			target.show_inv(source)
	qdel(src)

/mob/living/carbon/human/get_multitool(var/active_only=0)
	if(istype(get_active_hand(),/obj/item/device/multitool))
		return get_active_hand()
	if(active_only && istype(get_inactive_hand(),/obj/item/device/multitool))
		return get_inactive_hand()
	return null




