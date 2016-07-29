<<<<<<< HEAD
/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = 0)
	return dna.species.can_equip(I, slot, disable_warning, src)


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], qdel_on_fail = 0))
			return slot
	if(qdel_on_fail)
		qdel(I)
	return null


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


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot)
	if(!..()) //a check failed or the item has already found its slot
		return
	switch(slot)
		if(slot_belt)
			belt = I
			update_inv_belt()
		if(slot_wear_id)
			wear_id = I
			sec_hud_set_ID()
			update_inv_wear_id()
		if(slot_ears)
			ears = I
			update_inv_ears()
		if(slot_glasses)
			glasses = I
			var/obj/item/clothing/glasses/G = I
			if(G.tint)
				update_tint()
			if(G.vision_correction)
				clear_fullscreen("nearsighted")
			if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view)
				update_sight()
			update_inv_glasses()
		if(slot_gloves)
			gloves = I
			update_inv_gloves()
		if(slot_shoes)
			shoes = I
			update_inv_shoes()
		if(slot_wear_suit)
			wear_suit = I
			if(I.flags_inv & HIDEJUMPSUIT)
				update_inv_w_uniform()
			if(wear_suit.breakouttime) //when equipping a straightjacket
				stop_pulling() //can't pull if restrained
				update_action_buttons_icon() //certain action buttons will no longer be usable.
			update_inv_wear_suit()
		if(slot_w_uniform)
			w_uniform = I
			update_suit_sensors()
			update_inv_w_uniform()
		if(slot_l_store)
			l_store = I
			update_inv_pockets()
		if(slot_r_store)
			r_store = I
			update_inv_pockets()
		if(slot_s_store)
			s_store = I
			update_inv_s_store()
		else
			src << "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>"

/mob/living/carbon/human/unEquip(obj/item/I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return

	if(I == wear_suit)
		if(s_store)
			unEquip(s_store, 1) //It makes no sense for your suit storage to stay on you if you drop your suit.
		if(wear_suit.breakouttime) //when unequipping a straightjacket
			update_action_buttons_icon() //certain action buttons may be usable again.
		wear_suit = null
		if(I.flags_inv & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			unEquip(r_store, 1) //Again, makes sense for pockets to drop.
		if(l_store)
			unEquip(l_store, 1)
		if(wear_id)
			unEquip(wear_id)
		if(belt)
			unEquip(belt)
		w_uniform = null
		update_suit_sensors()
		update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		update_inv_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.tint)
			update_tint()
		if(G.vision_correction)
			if(disabilities & NEARSIGHT)
				overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view)
			update_sight()
		update_inv_glasses()
	else if(I == ears)
		ears = null
		update_inv_ears()
	else if(I == shoes)
		shoes = null
		update_inv_shoes()
	else if(I == belt)
		belt = null
		update_inv_belt()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		update_inv_wear_id()
	else if(I == r_store)
		r_store = null
		update_inv_pockets()
	else if(I == l_store)
		l_store = null
		update_inv_pockets()
	else if(I == s_store)
		s_store = null
		update_inv_s_store()

/mob/living/carbon/human/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	if((C.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || (initial(C.flags_inv) & (HIDEHAIR|HIDEFACIALHAIR)))
		update_hair()
	if(toggle_off && internal && !getorganslot("breathing_tube"))
		update_internals_hud_icon(0)
		internal = null
	if(C.flags_inv & HIDEEYES)
		update_inv_glasses()
	sec_hud_set_security_status()
	..()

/mob/living/carbon/human/head_update(obj/item/I, forced)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || forced)
		update_hair()
	if(I.flags_inv & HIDEEYES || forced)
		update_inv_glasses()
	if(I.flags_inv & HIDEEARS || forced)
		update_body()
	sec_hud_set_security_status()
	..()




//Cycles through all clothing slots and tests them for destruction
/mob/living/carbon/human/proc/shred_clothing(bomb,shock)
	var/covered_parts = 0	//The body parts that are protected by exterior clothing/armor
	var/head_absorbed = 0	//How much of the shock the headgear absorbs when it is shredded. -1=it survives
	var/suit_absorbed = 0	//How much of the shock the exosuit absorbs when it is shredded. -1=it survives

	//Backpacks can never be protected but are annoying as fuck to lose, so they get a lower chance to be shredded
	if(back)
		back.shred(bomb,shock-20,src)

	if(head)
		covered_parts |= head.flags_inv
		head_absorbed = head.shred(bomb,shock,src)
	if(wear_mask)
		var/absorbed = ((covered_parts & HIDEMASK) ? head_absorbed : 0) //Check if clothing covering this part absorbed any of the shock
		if(absorbed >= 0)
			//Masks can be used to shield other parts, but are simplified to simply add their absorbsion to the head armor if it covers the face
			var/mask_absorbed = wear_mask.shred(bomb,shock-absorbed,src)
			if(wear_mask.flags_inv & HIDEFACE)
				covered_parts |= wear_mask.flags_inv
				if(mask_absorbed < 0) //If the mask didn't get shredded, everything else on the head is protected
					head_absorbed = -1
				else
					head_absorbed += mask_absorbed
	if(ears)
		var/absorbed = ((covered_parts & HIDEEARS) ? head_absorbed : 0)
		if(absorbed >= 0)
			ears.shred(bomb,shock-absorbed,src)
	if(glasses)
		var/absorbed = ((covered_parts & HIDEEYES) ? head_absorbed : 0)
		if(absorbed >= 0)
			glasses.shred(bomb,shock-absorbed,src)

	if(wear_suit)
		covered_parts |= wear_suit.flags_inv
		suit_absorbed = wear_suit.shred(bomb,shock,src)
	if(gloves)
		var/absorbed = ((covered_parts & HIDEGLOVES) ? suit_absorbed : 0)
		if(absorbed >= 0)
			gloves.shred(bomb,shock-absorbed,src)
	if(shoes)
		var/absorbed = ((covered_parts & HIDESHOES) ? suit_absorbed : 0)
		if(absorbed >= 0)
			shoes.shred(bomb,shock-absorbed,src)
	if(w_uniform)
		var/absorbed = ((covered_parts & HIDEJUMPSUIT) ? suit_absorbed : 0)
		if(absorbed >= 0)
			w_uniform.shred(bomb,shock-20-absorbed,src)	//Uniforms are also annoying to get shredded

/obj/item/proc/shred(bomb,shock,mob/living/carbon/human/Human)
	if(flags & ABSTRACT)
		return -1

	var/shredded

	if(!bomb)
		if(burn_state != -1)
			shredded = 1 //No heat protection, it burns
		else
			shredded = -1 //Heat protection = Fireproof

	else if(shock > 0)
		if(prob(max(shock-armor["bomb"],0)))
			shredded = armor["bomb"] + 10 //It gets shredded, but it also absorbs the shock the clothes underneath would recieve by this amount
		else
			shredded = -1 //It survives explosion

	if(shredded > 0)
		if(Human) //Unequip if equipped
			Human.unEquip(src)

		if(bomb)
			empty_object_contents()
			spawn(1) //so the shreds aren't instantly deleted by the explosion
				var/obj/effect/decal/cleanable/shreds/Shreds = new(loc)
				Shreds.desc = "The sad remains of what used to be [src.name]."
				qdel(src)
		else
			burn()

	return shredded

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)
=======
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
			update_inv_hand(active_hand)
		else
			to_chat(H, "<span class='warning'>You are unable to equip that.</span>")

/mob/living/carbon/human/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
//ordered body items by which would appear on top
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
				l_store,
				r_store,
				s_store)
	return filter

/mob/living/carbon/human/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(is_slot_hidden(wear_suit.body_parts_covered,HIDEGLOVES))
			obscured |= slot_gloves
		if(is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT))
			obscured |= slot_w_uniform
		if(is_slot_hidden(wear_suit.body_parts_covered,HIDESHOES))
			obscured |= slot_shoes
	if(head)
		if(is_slot_hidden(head.body_parts_covered,HIDEMASK))
			obscured |= slot_wear_mask
		if(is_slot_hidden(head.body_parts_covered,HIDEEYES))
			obscured |= slot_glasses
		if(is_slot_hidden(head.body_parts_covered,HIDEEARS))
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
		items = get_clothing_items()
	items -= list(gloves,shoes,w_uniform,glasses,ears) // now that these can hide stuff they need to be excluded
	if(!hidden_flags)
		return
	var/ignore_slot
	for(var/obj/item/equipped in items)
		ignore_slot = (equipped == wear_mask) ? MOUTH : 0
		if(!equipped)
			continue
		else if(is_slot_hidden(equipped.body_parts_covered,hidden_flags,ignore_slot))
			return 1

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, act_on_fail = 1, put_in_hand_if_fail = 0)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], 0))
			return slot
	if(put_in_hand_if_fail)
		if (put_in_hands(W))
			return "hand"

	switch (act_on_fail)
		if(EQUIP_FAILACTION_DELETE)
			qdel(W)
			W = null
		if(EQUIP_FAILACTION_DROP)
			W.loc=get_turf(src) // I think.
	return null

/mob/living/carbon/human/proc/is_on_ears(var/typepath)
	return istype(ears,typepath)

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

/mob/living/carbon/human/has_organ(name)

	var/datum/organ/external/O = organs_by_name[name]
	return O.is_existing()

/mob/living/carbon/human/has_organ_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_organ(LIMB_CHEST)
		if(slot_wear_mask)
			return has_organ(LIMB_HEAD)
		if(slot_handcuffed)
			return has_organ(LIMB_LEFT_HAND) && has_organ(LIMB_RIGHT_HAND)
		if(slot_legcuffed)
			return has_organ(LIMB_LEFT_LEG) && has_organ(LIMB_RIGHT_LEG)
		if(slot_belt)
			return has_organ(LIMB_CHEST)
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return 1
		if(slot_ears)
			return has_organ(LIMB_HEAD)
		if(slot_glasses)
			return has_organ(LIMB_HEAD)
		if(slot_gloves)
			return has_organ(LIMB_LEFT_HAND) && has_organ(LIMB_RIGHT_HAND)
		if(slot_head)
			return has_organ(LIMB_HEAD)
		if(slot_shoes)
			return has_organ(LIMB_RIGHT_FOOT) && has_organ(LIMB_LEFT_FOOT)
		if(slot_wear_suit)
			return has_organ(LIMB_CHEST)
		if(slot_w_uniform)
			return has_organ(LIMB_CHEST)
		if(slot_l_store)
			return has_organ(LIMB_CHEST)
		if(slot_r_store)
			return has_organ(LIMB_CHEST)
		if(slot_s_store)
			return has_organ(LIMB_CHEST)
		if(slot_in_backpack)
			return 1

/mob/living/carbon/human/u_equip(obj/item/W as obj, dropped = 1)
	if(!W)	return 0

	var/success

	var/index = is_holding_item(W)
	if(index)
		held_items[index] = null
		success = 1
		update_inv_hand(index)
	else if (W == wear_suit)
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
		if(handcuffed.on_remove(src)) //If this returns 1, then the unquipping action was interrupted
			return 0
		handcuffed = null
		success = 1
		update_inv_handcuffed()
	else if (W == legcuffed)
		legcuffed = null
		success = 1
		update_inv_legcuffed()
	else
		return 0

	if(success)
		update_hidden_item_icons(W)

		if (W)
			if (client)
				client.screen -= W
			W.forceMove(loc)
			W.unequipped()
			if(dropped)
				W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
	update_action_buttons()
	return 1

//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/living/carbon/human/equip_to_slot_if_possible(obj/item/W as obj, slot, act_on_fail = 0, disable_warning = 0, redraw_mob = 1, automatic = 0)
	switch(W.mob_can_equip(src, slot, disable_warning, automatic))
		if(CANNOT_EQUIP)
			switch(act_on_fail)
				if(EQUIP_FAILACTION_DELETE)
					qdel(W)
					W = null
				if(EQUIP_FAILACTION_DROP)
					W.forceMove(get_turf(src)) //Should this be using drop_from_inventory instead?
				else
					if(!disable_warning)
						to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

			return 0
		if(CAN_EQUIP)
			equip_to_slot(W, slot, redraw_mob)
		if(CAN_EQUIP_BUT_SLOT_TAKEN)
			var/in_the_hand = (is_holding_item(W))
			var/obj/item/wearing = get_item_by_slot(slot)
			if(wearing)
				if(!in_the_hand) //if we aren't holding it, the proc is abstract so get rid of it
					switch(act_on_fail)
						if(EQUIP_FAILACTION_DELETE)
							qdel(W)
						if(EQUIP_FAILACTION_DROP)
							W.forceMove(get_turf(src)) //Should this be using drop_from_inventory instead?
					return

				if(drop_item(W))
					if(!put_in_active_hand(wearing))
						equip_to_slot(wearing, slot, redraw_mob)
						switch(act_on_fail)
							if(EQUIP_FAILACTION_DELETE)
								qdel(W)
							else
								if(!disable_warning && act_on_fail != EQUIP_FAILACTION_DROP)
									to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

						return
					else
						equip_to_slot(W, slot, redraw_mob)
						u_equip(wearing,0)
						put_in_active_hand(wearing)
					if(s_store && !s_store.mob_can_equip(src, slot_s_store, 1))
						u_equip(s_store,1)
	return 1


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)
	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return

	if(src.is_holding_item(W))
		src.u_equip(W)

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
	W.plane = PLANE_HUD
	W.equipped(src, slot)
	W.forceMove(src)
	if(client) client.screen |= W

/mob/living/carbon/human/get_multitool(var/active_only=0)
	if(istype(get_active_hand(),/obj/item/device/multitool))
		return get_active_hand()
	if(active_only && istype(get_inactive_hand(),/obj/item/device/multitool))
		return get_inactive_hand()
	return null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
