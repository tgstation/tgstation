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
