/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return wear_neck
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
	return null

/mob/living/carbon/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot], qdel_on_fail = 0, disable_warning = TRUE))
			return slot
	if(qdel_on_fail)
		qdel(I)
	return null

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE, swap = FALSE)
	if(!slot)
		return
	if(!istype(I))
		return

	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null
	if(client)
		client.screen -= I
	if(observers?.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client)
				observe.client.screen -= I
	I.forceMove(src)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	I.appearance_flags |= NO_CLIENT_COLOR
	var/not_handled = FALSE
	var/obj/item/current_equip
	switch(slot)
		if(ITEM_SLOT_BACK)
			if (back && swap)
				back.dropped(src, TRUE)
				current_equip = back
			back = I
			update_inv_back()
		if(ITEM_SLOT_MASK)
			if (wear_mask && swap)
				wear_mask.dropped(src, TRUE)
				current_equip = wear_mask
			wear_mask = I
			wear_mask_update(I, toggle_off = 0)
		if(ITEM_SLOT_HEAD)
			if (head && swap)
				head.dropped(src, TRUE)
				current_equip = head
			head = I
			SEND_SIGNAL(src, COMSIG_CARBON_EQUIP_HAT, I)
			head_update(I)
		if(ITEM_SLOT_NECK)
			if (wear_neck && swap)
				wear_neck.dropped(src, TRUE)
				current_equip = wear_neck
			wear_neck = I
			update_inv_neck(I)
		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(I)
			update_handcuffed()
		if(ITEM_SLOT_LEGCUFFED)
			legcuffed = I
			update_inv_legcuffed()
		if(ITEM_SLOT_HANDS)
			put_in_hands(I)
			update_inv_hands()
		if(ITEM_SLOT_BACKPACK)
			if(!back || !SEND_SIGNAL(back, COMSIG_TRY_STORAGE_INSERT, I, src, TRUE))
				not_handled = TRUE
		else
			not_handled = TRUE

	if (current_equip)
		put_in_active_hand(current_equip)

	//Item has been handled at this point and equipped callback can be safely called
	//We cannot call it for items that have not been handled as they are not yet correctly
	//in a slot (handled further down inheritance chain, probably living/carbon/human/equip_to_slot
	if(!not_handled)
		I.equipped(src, slot)

	return not_handled

/mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == head)
		head = null
		SEND_SIGNAL(src, COMSIG_CARBON_UNEQUIP_HAT, I, force, newloc, no_move, invdrop, silent)
		if(!QDELETED(src))
			head_update(I)
	else if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()
	else if(I == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			wear_mask_update(I, toggle_off = 1)
	if(I == wear_neck)
		wear_neck = null
		if(!QDELETED(src))
			update_inv_neck(I)
	else if(I == handcuffed)
		set_handcuffed(null)
		if(buckled?.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		if(!QDELETED(src))
			update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		if(!QDELETED(src))
			update_inv_legcuffed()

//handle stuff to update when a mob equips/unequips a mask.
/mob/living/proc/wear_mask_update(obj/item/I, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/I, toggle_off = 1)
	var/obj/item/clothing/C = I
	if(istype(C) && (C.tint || initial(C.tint)))
		update_tint()
	update_inv_wear_mask()

//handle stuff to update when a mob equips/unequips a headgear.
/mob/living/carbon/proc/head_update(obj/item/I, forced)
	if(istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if(C.tint || initial(C.tint))
			update_tint()
		update_sight()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()

/mob/living/carbon/proc/get_holding_bodypart_of_item(obj/item/I)
	var/index = get_held_index_of_item(I)
	return index && hand_bodyparts[index]

/**
  * Proc called when giving an item to another player
  *
  * This handles creating an alert and adding an overlay to it
  */
/mob/living/carbon/proc/give()
	var/obj/item/receiving = get_active_held_item()
	if(!receiving)
		to_chat(src, "<span class='warning'>You're not holding anything to give!</span>")
		return
	visible_message("<span class='notice'>[src] is offering [receiving]</span>", \
					"<span class='notice'>You offer [receiving]</span>", null, 2)
	for(var/mob/living/carbon/C in orange(1, src))
		if(!CanReach(C))
			continue
		var/obj/screen/alert/give/G = C.throw_alert("[src]", /obj/screen/alert/give)
		if(!G)
			continue
		G.setup(C, src, receiving)

/**
  * Proc called when the player clicks the give alert
  *
  * Handles checking if the player taking the item has open slots and is in range of the giver
  * Also deals with the actual transferring of the item to the players hands
  * Arguments:
  * * giver - The person giving the original item
  * * I - The item being given by the giver
  */
/mob/living/carbon/proc/take(mob/living/carbon/giver, obj/item/I)
	clear_alert("[giver]")
	if(get_dist(src, giver) > 1)
		to_chat(src, "<span class='warning'>[giver] is out of range! </span>")
		return
	if(!I || giver.get_active_held_item() != I)
		to_chat(src, "<span class='warning'>[giver] is no longer holding the item they were offering! </span>")
		return
	if(!get_empty_held_indexes())
		to_chat(src, "<span class='warning'>You have no empty hands!</span>")
		return
	if(!giver.temporarilyRemoveItemFromInventory(I))
		visible_message("<span class='notice'>[giver] tries to hand over [I] but it's stuck to them....</span>")
		return
	visible_message("<span class='notice'>[src] takes [I] from [giver]</span>", \
					"<span class='notice'>You take [I] from [giver]</span>")
	put_in_hands(I)
