/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, swap = FALSE)
	return dna.species.can_equip(I, slot, disable_warning, src, bypass_equip_delay_self, swap)

// Return the item currently in the slot ID
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
		if(ITEM_SLOT_BELT)
			return belt
		if(ITEM_SLOT_ID)
			return wear_id
		if(ITEM_SLOT_EARS)
			return ears
		if(ITEM_SLOT_EYES)
			return glasses
		if(ITEM_SLOT_GLOVES)
			return gloves
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_FEET)
			return shoes
		if(ITEM_SLOT_OCLOTHING)
			return wear_suit
		if(ITEM_SLOT_ICLOTHING)
			return w_uniform
		if(ITEM_SLOT_LPOCKET)
			return l_store
		if(ITEM_SLOT_RPOCKET)
			return r_store
		if(ITEM_SLOT_SUITSTORE)
			return s_store
	return null

/mob/living/carbon/human/proc/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
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
		w_uniform
		)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		wear_neck,
		glasses,
		ears,
		)

/mob/living/carbon/human/proc/get_storage_slots()
	return list(
		back,
		belt,
		l_store,
		r_store,
		s_store,
		)

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE, swap = FALSE)
	if(!..()) //a check failed or the item has already found its slot
		return

	var/obj/item/current_equip
	var/not_handled = FALSE //Added in case we make this type path deeper one day
	switch(slot)
		if(ITEM_SLOT_BELT)
			if (belt && swap)
				belt.dropped(src, TRUE)
				current_equip = belt
			belt = I
			update_inv_belt()
		if(ITEM_SLOT_ID)
			if (wear_id && swap)
				wear_id.dropped(src, TRUE)
				current_equip = wear_id
			wear_id = I
			sec_hud_set_ID()
			update_inv_wear_id()
		if(ITEM_SLOT_EARS)
			if (ears && swap)
				ears.dropped(src, TRUE)
				current_equip = ears
			ears = I
			update_inv_ears()
		if(ITEM_SLOT_EYES)
			if (glasses && swap)
				glasses.dropped(src, TRUE)
				current_equip = glasses
			glasses = I
			var/obj/item/clothing/glasses/G = I
			if(G.glass_colour_type)
				update_glasses_color(G, 1)
			if(G.tint)
				update_tint()
			if(G.vision_correction)
				clear_fullscreen("nearsighted")
			if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
				update_sight()
			update_inv_glasses()
		if(ITEM_SLOT_GLOVES)
			if (gloves && swap)
				gloves.dropped(src, TRUE)
				current_equip = gloves
			gloves = I
			update_inv_gloves()
		if(ITEM_SLOT_FEET)
			if (shoes && swap)
				shoes.dropped(src, TRUE)
				current_equip = shoes
			shoes = I
			update_inv_shoes()
		if(ITEM_SLOT_OCLOTHING)
			if (wear_suit && swap)
				wear_suit.dropped(src, TRUE)
				current_equip = wear_suit

			wear_suit = I

			if (s_store && swap)
				var/obj/item/s_store_backup = s_store
				dropItemToGround(s_store_backup)
				put_in_inactive_hand(s_store_backup)
				equip_to_slot_if_possible(s_store_backup, ITEM_SLOT_SUITSTORE)

			if(I.flags_inv & HIDEJUMPSUIT)
				update_inv_w_uniform()
			if(wear_suit.breakouttime) //when equipping a straightjacket
				ADD_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
				stop_pulling() //can't pull if restrained
				update_action_buttons_icon() //certain action buttons will no longer be usable.
			update_inv_wear_suit()
		if(ITEM_SLOT_ICLOTHING)
			if (w_uniform && swap)
				w_uniform.dropped(src, TRUE)
				current_equip = w_uniform
			w_uniform = I
			update_suit_sensors()
			update_inv_w_uniform()
		if(ITEM_SLOT_LPOCKET)
			l_store = I
			update_inv_pockets()
		if(ITEM_SLOT_RPOCKET)
			r_store = I
			update_inv_pockets()
		if(ITEM_SLOT_SUITSTORE)
			if (s_store && swap)
				s_store.dropped(src, TRUE)
				current_equip = s_store
			s_store = I
			update_inv_s_store()
		else
			to_chat(src, "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")

	if (current_equip)
		put_in_active_hand(current_equip)

	//Item is handled and in slot, valid to call callback, for this proc should always be true
	if(!not_handled)
		I.equipped(src, slot, initial)

		// Send a signal for when we equip an item that used to cover our feet/shoes. Used for bloody feet
		if((I.body_parts_covered & FEET) || (I.flags_inv | I.transparent_protection) & HIDESHOES)
			SEND_SIGNAL(src, COMSIG_CARBON_EQUIP_SHOECOVER, I, slot, initial, redraw_mob, swap)

	return not_handled //For future deeper overrides

/mob/living/carbon/human/equipped_speed_mods()
	. = ..()
	for(var/sloties in get_all_slots() - list(l_store, r_store, s_store))
		var/obj/item/thing = sloties
		. += thing?.slowdown

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	var/index = get_held_index_of_item(I)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return
	if(index && !QDELETED(src) && dna.species.mutanthands) //hand freed, fill with claws, skip if we're getting deleted.
		put_in_hand(new dna.species.mutanthands(), index)
	if(I == wear_suit)
		if(s_store && invdrop)
			dropItemToGround(s_store, TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.
		if(wear_suit.breakouttime) //when unequipping a straightjacket
			REMOVE_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
			drop_all_held_items() //suit is restraining
			update_action_buttons_icon() //certain action buttons may be usable again.
		wear_suit = null
		if(!QDELETED(src)) //no need to update we're getting deleted anyway
			if(I.flags_inv & HIDEJUMPSUIT)
				update_inv_w_uniform()
			update_inv_wear_suit()
	else if(I == w_uniform)
		if(invdrop)
			if(r_store)
				dropItemToGround(r_store, TRUE) //Again, makes sense for pockets to drop.
			if(l_store)
				dropItemToGround(l_store, TRUE)
			if(wear_id)
				dropItemToGround(wear_id)
			if(belt)
				dropItemToGround(belt)
		w_uniform = null
		update_suit_sensors()
		if(!QDELETED(src))
			update_inv_w_uniform()
	else if(I == gloves)
		gloves = null
		if(!QDELETED(src))
			update_inv_gloves()
	else if(I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.glass_colour_type)
			update_glasses_color(G, 0)
		if(G.tint)
			update_tint()
		if(G.vision_correction)
			if(HAS_TRAIT(src, TRAIT_NEARSIGHT))
				overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
			update_sight()
		if(!QDELETED(src))
			update_inv_glasses()
	else if(I == ears)
		ears = null
		if(!QDELETED(src))
			update_inv_ears()
	else if(I == shoes)
		shoes = null
		if(!QDELETED(src))
			update_inv_shoes()
	else if(I == belt)
		belt = null
		if(!QDELETED(src))
			update_inv_belt()
	else if(I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		if(!QDELETED(src))
			update_inv_wear_id()
	else if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()
	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()
	else if(I == s_store)
		s_store = null
		if(!QDELETED(src))
			update_inv_s_store()

	// Send a signal for when we unequip an item that used to cover our feet/shoes. Used for bloody feet
	if((I.body_parts_covered & FEET) || (I.flags_inv | I.transparent_protection) & HIDESHOES)
		SEND_SIGNAL(src, COMSIG_CARBON_UNEQUIP_SHOECOVER, I, force, newloc, no_move, invdrop, silent)

/mob/living/carbon/human/wear_mask_update(obj/item/I, toggle_off = 1)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || (initial(I.flags_inv) & (HIDEHAIR|HIDEFACIALHAIR)))
		update_hair()
	if(toggle_off && internal && !getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		update_internals_hud_icon(0)
		internal = null
	if(I.flags_inv & HIDEEYES)
		update_inv_glasses()
	sec_hud_set_security_status()
	..()

/mob/living/carbon/human/head_update(obj/item/I, forced)
	if((I.flags_inv & (HIDEHAIR|HIDEFACIALHAIR)) || forced)
		update_hair()
	else
		var/obj/item/clothing/C = I
		if(istype(C) && C.dynamic_hair_suffix)
			update_hair()
	if(I.flags_inv & HIDEEYES || forced)
		update_inv_glasses()
	if(I.flags_inv & HIDEEARS || forced)
		update_body()
	sec_hud_set_security_status()
	..()

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


//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_all_slots())//order matters, dependant slots go first
		qdel(slot)
	for(var/obj/item/I in held_items)
		qdel(I)

/// take the most recent item out of a slot or place held item in a slot

/mob/living/carbon/human/proc/smart_equip_targeted(slot_type = ITEM_SLOT_BELT, slot_item_name = "belt")
	if(incapacitated())
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_item = get_item_by_slot(slot_type)
	if(!equipped_item) // We also let you equip an item like this
		if(!thing)
			to_chat(src, "<span class='warning'>You have no [slot_item_name] to take something out of!</span>")
			return
		if(equip_to_slot_if_possible(thing, slot_type))
			update_inv_hands()
		return
	if(!SEND_SIGNAL(equipped_item, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_item.attack_hand(src)
		else
			to_chat(src, "<span class='warning'>You can't fit [thing] into your [equipped_item.name]!</span>")
		return
	if(thing) // put thing in storage item
		if(!SEND_SIGNAL(equipped_item, COMSIG_TRY_STORAGE_INSERT, thing, src))
			to_chat(src, "<span class='warning'>You can't fit [thing] into your [equipped_item.name]!</span>")
		return
	if(!equipped_item.contents.len) // nothing to take out
		to_chat(src, "<span class='warning'>There's nothing in your [equipped_item.name] to take out!</span>")
		return
	var/obj/item/stored = equipped_item.contents[equipped_item.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from item in storage slot
	return

