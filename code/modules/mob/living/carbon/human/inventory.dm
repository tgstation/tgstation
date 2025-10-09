
/**
 * Used to return a list of equipped items on a human mob; does not by default include held items, see include_flags
 *
 * Argument(s):
 * * Optional - include_flags, (see obj.flags.dm) describes which optional things to include or not (pockets, accessories, held items)
 */

/mob/living/carbon/human/get_equipped_items(include_flags = NONE)
	var/list/items = ..()
	if(!(include_flags & INCLUDE_POCKETS))
		items -= list(l_store, r_store, s_store)
	if((include_flags & INCLUDE_ACCESSORIES) && w_uniform)
		var/obj/item/clothing/under/worn_under = w_uniform
		items += worn_under.attached_accessories
	return items

/mob/living/carbon/human/can_equip(obj/item/equip_target, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(SEND_SIGNAL(src, COMSIG_HUMAN_EQUIPPING_ITEM, equip_target, slot) == COMPONENT_BLOCK_EQUIP)
		return FALSE
	if(HAS_TRAIT(equip_target, TRAIT_NODROP) && (equip_target in held_items))
		if(!disable_warning)
			to_chat(src, span_warning("[equip_target] won't budge, it's impossible to put it on!"))
		return FALSE
	return dna.species.can_equip(equip_target, slot, disable_warning, src, bypass_equip_delay_self, ignore_equipped, indirect_action)

/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
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

	return ..()

/mob/living/carbon/human/get_slot_by_item(obj/item/looking_for)
	if(looking_for == belt)
		return ITEM_SLOT_BELT

	if(looking_for == wear_id)
		return ITEM_SLOT_ID

	if(looking_for == ears)
		return ITEM_SLOT_EARS

	if(looking_for == glasses)
		return ITEM_SLOT_EYES

	if(looking_for == gloves)
		return ITEM_SLOT_GLOVES

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	if(looking_for == shoes)
		return ITEM_SLOT_FEET

	if(looking_for == wear_suit)
		return ITEM_SLOT_OCLOTHING

	if(looking_for == w_uniform)
		return ITEM_SLOT_ICLOTHING

	if(looking_for == r_store)
		return ITEM_SLOT_RPOCKET

	if(looking_for == l_store)
		return ITEM_SLOT_LPOCKET

	if(looking_for == s_store)
		return ITEM_SLOT_SUITSTORE

	return ..()

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

/mob/living/carbon/human/get_visible_items()
	var/list/visible_items = ..()
	var/obj/item/clothing/under/under = w_uniform
	if(istype(under) && length(under.attached_accessories) && (under in visible_items))
		visible_items += under.attached_accessories
	return visible_items

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/mob/living/carbon/human/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!..()) //a check failed or the item has already found its slot
		return

	var/not_handled = FALSE //Added in case we make this type path deeper one day
	switch(slot)
		if(ITEM_SLOT_BELT)
			if(belt)
				return
			belt = equipping
			update_worn_belt()
		if(ITEM_SLOT_ID)
			if(wear_id)
				return
			wear_id = equipping
			update_ID_card()
			update_worn_id()
		if(ITEM_SLOT_EARS)
			if(ears)
				return
			ears = equipping
			update_worn_ears()
		if(ITEM_SLOT_EYES)
			if(glasses)
				return
			glasses = equipping
			if(glasses.vision_flags || glasses.invis_override || glasses.invis_view || !isnull(glasses.lighting_cutoff))
				update_sight()
			update_worn_glasses()
		if(ITEM_SLOT_GLOVES)
			if(gloves)
				return
			gloves = equipping
			update_worn_gloves()
		if(ITEM_SLOT_FEET)
			if(shoes)
				return
			shoes = equipping
			update_worn_shoes()
		if(ITEM_SLOT_OCLOTHING)
			if(wear_suit)
				return
			wear_suit = equipping
			if(wear_suit.breakouttime) //when equipping a straightjacket
				ADD_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
				stop_pulling() //can't pull if restrained
				update_mob_action_buttons() //certain action buttons will no longer be usable.
			update_worn_oversuit()
		if(ITEM_SLOT_ICLOTHING)
			if(w_uniform)
				return
			w_uniform = equipping
			update_worn_undersuit()
		if(ITEM_SLOT_LPOCKET)
			l_store = equipping
			update_pockets()
		if(ITEM_SLOT_RPOCKET)
			r_store = equipping
			update_pockets()
		if(ITEM_SLOT_SUITSTORE)
			if(s_store)
				return
			s_store = equipping
			update_suit_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			not_handled = TRUE

	//Item is handled and in slot, valid to call callback, for this proc should always be true
	if(!not_handled)
		has_equipped(equipping, slot, initial)

	return not_handled //For future deeper overrides

/mob/living/carbon/human/get_equipped_speed_mod_items()
	return ..() - list(l_store, r_store, s_store)

/mob/living/carbon/human/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !item_dropping)
		return
	if(item_dropping == wear_suit)
		if(s_store && invdrop)
			dropItemToGround(s_store, TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.
		if(wear_suit.breakouttime) //when unequipping a straightjacket
			REMOVE_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)
			drop_all_held_items() //suit is restraining
			update_mob_action_buttons() //certain action buttons may be usable again.
		wear_suit = null
		if(!QDELETED(src)) //no need to update we're getting deleted anyway
			update_worn_oversuit()
	else if(item_dropping == w_uniform)
		w_uniform = null
		if(!QDELETED(src))
			update_worn_undersuit()
		if(invdrop)
			if(r_store && !can_equip(r_store, ITEM_SLOT_RPOCKET, TRUE, ignore_equipped = TRUE))
				dropItemToGround(r_store, TRUE) //Again, makes sense for pockets to drop.
			if(l_store && !can_equip(l_store, ITEM_SLOT_LPOCKET, TRUE, ignore_equipped = TRUE))
				dropItemToGround(l_store, TRUE)
			if(wear_id && !can_equip(wear_id, ITEM_SLOT_ID, TRUE, ignore_equipped = TRUE))
				dropItemToGround(wear_id)
			if(belt && !can_equip(belt, ITEM_SLOT_BELT, TRUE, ignore_equipped = TRUE))
				dropItemToGround(belt)
	else if(item_dropping == gloves)
		gloves = null
		if(!QDELETED(src))
			update_worn_gloves()
	else if(item_dropping == glasses)
		glasses = null
		var/obj/item/clothing/glasses/old_glasses = item_dropping
		if(old_glasses.vision_flags || old_glasses.invis_override || old_glasses.invis_view || !isnull(old_glasses.lighting_cutoff))
			update_sight()
		if(!QDELETED(src))
			update_worn_glasses()
	else if(item_dropping == ears)
		ears = null
		if(!QDELETED(src))
			update_worn_ears()
	else if(item_dropping == shoes)
		shoes = null
		if(!QDELETED(src))
			update_worn_shoes()
	else if(item_dropping == belt)
		belt = null
		if(!QDELETED(src))
			update_worn_belt()
	else if(item_dropping == wear_id)
		wear_id = null
		update_ID_card()
		if(!QDELETED(src))
			update_worn_id()
	else if(item_dropping == r_store)
		r_store = null
		if(!QDELETED(src))
			update_pockets()
	else if(item_dropping == l_store)
		l_store = null
		if(!QDELETED(src))
			update_pockets()
	else if(item_dropping == s_store)
		s_store = null
		if(!QDELETED(src))
			update_suit_storage()

/mob/living/carbon/human/item_coverage_changed(added_slots, removed_slots)
	. = ..()
	if((added_slots|removed_slots) & HIDEFACE)
		sec_hud_set_security_status()
		update_visible_name()

/mob/living/carbon/human/toggle_internals(obj/item/tank, is_external = FALSE)
	// Just close the tank if it's the one the mob already has open.
	var/obj/item/existing_tank = is_external ? external : internal
	if(tank == existing_tank)
		return toggle_close_internals(is_external)
	// Use breathing tube regardless of mask.
	if(can_breathe_tube())
		return toggle_open_internals(tank, is_external)
	// Use mask in absence of tube.
	if(isclothing(wear_mask) && ((wear_mask.visor_flags & MASKINTERNALS) || (wear_mask.clothing_flags & MASKINTERNALS)))
		// Adjust dishevelled breathing mask back onto face unless it is exempt.
		if ((wear_mask.up) && !(wear_mask.clothing_flags & INTERNALS_ADJUST_EXEMPT))
			wear_mask.adjust_visor(src)
		return toggle_open_internals(tank, is_external)
	// Use helmet in absence of tube or valid mask.
	if(can_breathe_helmet())
		return toggle_open_internals(tank, is_external)
	// Notify user of missing valid breathing apparatus.
	if (wear_mask)
		// Invalid mask
		to_chat(src, span_warning("[wear_mask] can't use [tank]!"))
	else if (head)
		// Invalid headgear
		to_chat(src, span_warning("[head] isn't airtight! You need a mask!"))
	else
		// Not wearing any breathing apparatus.
		to_chat(src, span_warning("You need a mask!"))

/// Returns TRUE if the tank successfully toggles open/closed. Opens the tank only if a breathing apparatus is found.
/mob/living/carbon/human/toggle_externals(obj/item/tank)
	return toggle_internals(tank, TRUE)

/mob/living/carbon/human/proc/equipOutfit(outfit, visuals_only = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visuals_only)


///A version of equipOutfit that overrides passed in outfits with their entry on the species' outfit override registry
/mob/living/carbon/human/proc/equip_species_outfit(outfit, visuals_only = FALSE)
	var/datum/outfit/outfit_to_equip

	var/override_outfit_path = dna?.species.outfit_override_registry[outfit]
	if(override_outfit_path)
		outfit_to_equip = new override_outfit_path
	else
		outfit_to_equip = new outfit

	if(isnull(outfit_to_equip))
		return FALSE

	return outfit_to_equip.equip(src, visuals_only)


//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_equipped_items(INCLUDE_POCKETS))//order matters, dependant slots go first
		qdel(slot)
	for(var/obj/item/held_item in held_items)
		qdel(held_item)

/// take the most recent item out of a slot or place held item in a slot

/mob/living/carbon/human/proc/smart_equip_targeted(slot_type = ITEM_SLOT_BELT, slot_item_name = "belt")
	if(incapacitated)
		return
	var/obj/item/thing = get_active_held_item()
	var/obj/item/equipped_item = get_item_by_slot(slot_type)
	if(!equipped_item) // We also let you equip an item like this
		if(!thing)
			to_chat(src, span_warning("You have no [slot_item_name] to take something out of!"))
			return
		if(equip_to_slot_if_possible(thing, slot_type))
			update_held_items()
		return
	var/datum/storage/storage = equipped_item.atom_storage
	if(!storage)
		if(!thing)
			equipped_item.attack_hand(src)
		else
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return
	if(!storage.supports_smart_equip)
		return
	if (equipped_item.atom_storage.locked) // Determines if container is locked before trying to put something in or take something out so we dont give out information on contents (or lack of)
		to_chat(src, span_warning("\The [equipped_item] is locked!"))
		return
	if(thing) // put thing in storage item
		if(!equipped_item.atom_storage?.attempt_insert(thing, src))
			to_chat(src, span_warning("You can't fit [thing] into your [equipped_item.name]!"))
		return
	if(!storage.real_location.contents.len) // nothing to take out
		to_chat(src, span_warning("There's nothing in your [equipped_item.name] to take out!"))
		return
	var/obj/item/stored = storage.real_location.contents[storage.real_location.contents.len]
	if(!stored || stored.on_found(src))
		return
	stored.attack_hand(src) // take out thing from item in storage slot
	return

/mob/living/carbon/human/change_number_of_hands(amt)
	var/old_limbs = held_items.len
	if(amt < old_limbs)
		for(var/i in hand_bodyparts.len to amt step -1)
			var/obj/item/bodypart/BP = hand_bodyparts[i]
			BP.dismember()
			hand_bodyparts[i] = null
		hand_bodyparts.len = amt
	else if(amt > old_limbs)
		hand_bodyparts.len = amt
		for(var/i in old_limbs + 1 to amt)
			var/obj/item/bodypart/new_bodypart
			if(IS_RIGHT_INDEX(i))
				new_bodypart = newBodyPart(BODY_ZONE_R_ARM)
			else
				new_bodypart = newBodyPart(BODY_ZONE_L_ARM)

			new_bodypart.held_index = i
			new_bodypart.try_attach_limb(src, TRUE)
			hand_bodyparts[i] = new_bodypart
	..() //Don't redraw hands until we have organs for them
