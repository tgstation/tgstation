/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
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
			return has_organ("groin")
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
			return has_organ("groin")
		if(slot_r_store)
			return has_organ("chest")
		if(slot_s_store)
			return has_organ("chest")
		if(slot_in_backpack)
			return 1

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if(!W)	return 0

	var/success

	if (W == wear_suit)
		if(s_store)
			u_equip(s_store)
		if(W)
			success = 1
		wear_suit = null
		update_inv_wear_suit()
	else if (W == w_uniform)
		if (r_store)
			u_equip(r_store)
		if (l_store)
			u_equip(l_store)
		if (wear_id)
			u_equip(wear_id)
		if (belt)
			u_equip(belt)
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
		if(W.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
		success = 1
		update_inv_head()
	else if (W == ears)
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
		if(W.flags & BLOCKHAIR)
			update_hair(0)	//rebuild hair
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
		if (W)
			if (client)
				client.screen -= W
			W.loc = loc
			W.dropped(src)
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
	else if(W == src.r_hand)
		src.r_hand = null

	W.loc = src
	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			if(wear_mask.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id(redraw_mob)
		if(slot_ears)
			src.ears = W
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			if(head.flags & BLOCKHAIR)
				update_hair(redraw_mob)	//rebuild hair
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			W.equipped(src, slot)
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.u_equip(W)
			W.loc = src.back
		else
			src << "\red You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it..."
			return

	W.layer = 20

	return




/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null	//source location
	var/t_loc = null	//target location
	var/obj/item/item = null
	var/place = null

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		del(src)
	spawn(100)
		del(src)
	..()
	return

/obj/effect/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					del(src)
			if("l_hand")
				if (!( target.l_hand ))
					del(src)
			if("r_hand")
				if (!( target.r_hand ))
					del(src)
			if("suit")
				if (!( target.wear_suit ))
					del(src)
			if("uniform")
				if (!( target.w_uniform ))
					del(src)
			if("back")
				if (!( target.back ))
					del(src)
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
					del(src)
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					del(src)
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					del(src)

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		if(isrobot(source) && place != "handcuff")
			del(src)
		for(var/mob/O in viewers(target, null))
			O.show_message("\red <B>[source] is trying to put \a [item] on [target]</B>", 1)
	else
		var/message=null
		switch(place)
			if("syringe")
				message = "\red <B>[source] is trying to inject [target]!</B>"
			if("pill")
				message = "\red <B>[source] is trying to force [target] to swallow [item]!</B>"
			if("drink")
				message = "\red <B>[source] is trying to force [target] to swallow a gulp of [item]!</B>"
			if("dnainjector")
				message = "\red <B>[source] is trying to inject [target] with the [item]!</B>"
			if("mask")
				if(target.wear_mask && !target.wear_mask.canremove)
					message = "\red <B>[source] fails to take off \a [target.wear_mask] from [target]'s head!</B>"
				else
					message = "\red <B>[source] is trying to take off \a [source.wear_mask] from [target]'s head!</B>"
			if("l_hand")
				message = "\red <B>[source] is trying to take off \a [target.l_hand] from [target]'s left hand!</B>"
			if("r_hand")
				message = "\red <B>[source] is trying to take off \a [target.r_hand] from [target]'s right hand!</B>"
			if("gloves")
				if(target.gloves && !target.gloves.canremove)
					message = "\red <B>[source] fails to take off \a [target.gloves] from [target]'s hands!</B>"
				else
					message = "\red <B>[source] is trying to take off the [target.gloves] from [target]'s hands!</B>"
			if("eyes")
				if(target.glasses && !target.glasses.canremove)
					message = "\red <B>[source] fails to take off \a [target.glasses] from [target]'s eyes!</B>"
				else
					message = "\red <B>[source] is trying to take off the [target.glasses] from [target]'s eyes!</B>"
			if("ears")
				if(target.ears && !target.ears.canremove)
					message = "\red <B>[source] fails to take off \a [target.ears] from [target]'s ears!</B>"
				else
					message = "\red <B>[source] is trying to take off the [target.ears] from [target]'s ears!</B>"
			if("head")
				if(target.head && !target.head.canremove)
					message = "\red <B>[source] fails to take off \a [target.head] from [target]'s head!</B>"
				else
					message = "\red <B>[source] is trying to take off the [target.head] from [target]'s head!</B>"
			if("shoes")
				if(target.shoes && !target.shoes.canremove)
					message = "\red <B>[source] fails to take off \a [target.shoes] from [target]'s feet!</B>"
				else
					message = "\red <B>[source] is trying to take off the [target.shoes] from [target]'s feet!</B>"
			if("belt")
				message = "\red <B>[source] is trying to take off the [target.belt] from [target]'s belt!</B>"
			if("suit")
				if(target.wear_suit && !target.wear_suit.canremove)
					message = "\red <B>[source] fails to take off \a [target.wear_suit] from [target]'s body!</B>"
				else
					message = "\red <B>[source] is trying to take off \a [target.wear_suit] from [target]'s body!</B>"
			if("back")
				message = "\red <B>[source] is trying to take off \a [target.back] from [target]'s back!</B>"
			if("handcuff")
				message = "\red <B>[source] is trying to unhandcuff [target]!</B>"
			if("legcuff")
				message = "\red <B>[source] is trying to unlegcuff [target]!</B>"
			if("uniform")
				if(target.w_uniform && !target.w_uniform.canremove)
					message = "\red <B>[source] fails to take off \a [target.w_uniform] from [target]'s body!</B>"
				else
					message = "\red <B>[source] is trying to take off \a [target.w_uniform] from [target]'s body!</B>"
			if("s_store")
				message = "\red <B>[source] is trying to take off \a [target.s_store] from [target]'s suit!</B>"
			if("pockets")
				for(var/obj/item/weapon/mousetrap/MT in  list(target.l_store, target.r_store))
					if(MT.armed)
						for(var/mob/O in viewers(target, null))
							if(O == source)
								O.show_message("\red <B>You reach into the [target]'s pockets, but there was a live mousetrap in there!</B>", 1)
							else
								O.show_message("\red <B>[source] reaches into [target]'s pockets and sets off a hidden mousetrap!</B>", 1)
						target.u_equip(MT)
						if (target.client)
							target.client.screen -= MT
						MT.loc = source.loc
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
						MT.layer = OBJ_LAYER
						return
				message = "\red <B>[source] is trying to empty [target]'s pockets.</B>"
			if("CPR")
				if (target.cpr_time >= world.time + 3)
					del(src)
				message = "\red <B>[source] is trying perform CPR on [target]!</B>"
			if("id")
				message = "\red <B>[source] is trying to take off [target.wear_id] from [target]'s uniform!</B>"
			if("internal")
				if (target.internal)
					message = "\red <B>[source] is trying to remove [target]'s internals</B>"
				else
					message = "\red <B>[source] is trying to set on [target]'s internals.</B>"
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( HUMAN_STRIP_DELAY )
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
	if(!source || !target) return		//Target or source no longer exist
	if(source.loc != s_loc) return		//source has moved
	if(target.loc != t_loc) return		//target has moved
	if(LinkBlocked(s_loc,t_loc)) return	//Use a proxi!
	if(item && source.get_active_hand() != item) return	//Swapped hands / removed item from the active one
	if ((source.restrained() || source.stat)) return //Source restrained or unconscious / dead

	var/slot_to_process
	var/strip_item //this will tell us which item we will be stripping - if any.

	switch(place)	//here we go again...
		if("mask")
			slot_to_process = slot_wear_mask
			if (target.wear_mask)
				strip_item = target.wear_mask
		if("gloves")
			slot_to_process = slot_gloves
			if (target.gloves)
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
			if (target.head)
				strip_item = target.head
		if("ears")
			slot_to_process = slot_ears
			if (target.ears)
				strip_item = target.ears
		if("shoes")
			slot_to_process = slot_shoes
			if (target.shoes)
				strip_item = target.shoes
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = slot_l_hand
			if (target.l_hand)
				strip_item = target.l_hand
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = slot_r_hand
			if (target.r_hand)
				strip_item = target.r_hand
		if("uniform")
			slot_to_process = slot_w_uniform
			if (target.w_uniform)
				strip_item = target.w_uniform
		if("suit")
			slot_to_process = slot_wear_suit
			if (target.wear_suit)
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
		if("CPR")
			if (target.cpr_time >= world.time + 30)
				del(src)
			if ((target.health >= -99.0 && target.health <= 0))
				target.cpr_time = world.time
				var/suff = min(target.getOxyLoss(), 7)
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message("\red [source] performs CPR on [target]!", 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat at least every 7 seconds."
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(S)
				S.add_fingerprint(source)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					S.inuse = 0
					del(src)
				S.inject(target, source)
				if (S.s_time >= world.time + 30)
					S.inuse = 0
					del(src)
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message("\red [source] injects [target] with the DNA Injector!", 1)
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
							M.show_message("[source] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
	if(slot_to_process)
		if(strip_item) //Stripping an item from the mob
			target.u_equip(strip_item)
			if(slot_to_process == slot_l_store) //pockets! Needs to process the other one too. Snowflake code, wooo! It's not like anyone will rewrite this anytime soon. If I'm wrong then... CONGRATULATIONS! ;)
				if(target.r_store)
					target.u_equip(target.r_store) //At this stage l_store is already processed by the code above, we only need to process r_store.
		else
			if(item && target.has_organ_for_slot(slot_to_process)) //Placing an item on the mob
				if(item.mob_can_equip(target, slot_to_process, 0))
					source.u_equip(item)
					target.equip_to_slot_if_possible(item, slot_to_process, 0, 1, 1)
					source.update_icons()
					target.update_icons()

	if(source && target)
		if(source.machine == target)
			target.show_inv(source)
	del(src)