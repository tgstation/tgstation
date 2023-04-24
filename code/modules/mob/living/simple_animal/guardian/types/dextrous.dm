//Dextrous
/mob/living/simple_animal/hostile/guardian/dextrous
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>dextrous</b> type you can hold items, store an item within yourself, and have medium damage resistance, but do low damage on attacks. Recalling and leashing will force you to drop unstored items!")
	magic_fluff_string = span_holoparasite("..And draw the Drone, a dextrous master of construction and repair.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Dextrous combat modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! It can hold stuff in its fins, sort of.")
	miner_fluff_string = span_holoparasite("You encounter... Gold, a malleable constructor.")
	creator_name = "Dextrous"
	creator_desc = "Does low damage on attack, but is capable of holding items and storing a single item within it. It will drop items held in its hands when it recalls, but it will retain the stored item."
	creator_icon = "dextrous"
	dextrous = TRUE
	held_items = list(null, null)
	var/obj/item/internal_storage //what we're storing within ourself

/mob/living/simple_animal/hostile/guardian/dextrous/death(gibbed)
	. = ..()
	if(internal_storage)
		dropItemToGround(internal_storage)

/mob/living/simple_animal/hostile/guardian/dextrous/examine(mob/user)
	if(dextrous)
		. = list("<span class='info'>This is [icon2html(src)] \a <b>[src]</b>!\n[desc]")
		for(var/obj/item/held_item in held_items)
			if(held_item.item_flags & (ABSTRACT|EXAMINE_SKIP|HAND_ITEM))
				continue
			. += "It has [held_item.get_examine_string(user)] in its [get_held_index_name(get_held_index_of_item(held_item))]."
		if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
			. += "It is holding [internal_storage.get_examine_string(user)] in its internal storage."
		. += "</span>"
	else
		return ..()

/mob/living/simple_animal/hostile/guardian/dextrous/recall_effects()
	drop_all_held_items()

/mob/living/simple_animal/hostile/guardian/dextrous/check_distance()
	if(!summoner || get_dist(get_turf(summoner), get_turf(src)) <= range)
		return
	drop_all_held_items()
	..() //lose items, then return

//SLOT HANDLING BULLSHIT FOR INTERNAL STORAGE
/mob/living/simple_animal/hostile/guardian/dextrous/doUnEquip(obj/item/equipped_item, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(equipped_item == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/dextrous/can_equip(obj/item/equipped_item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			if(internal_storage)
				return FALSE
			return TRUE
	..()

/mob/living/simple_animal/hostile/guardian/dextrous/get_item_by_slot(slot_id)
	if(slot_id == ITEM_SLOT_DEX_STORAGE)
		return internal_storage
	return ..()

/mob/living/simple_animal/hostile/guardian/dextrous/get_slot_by_item(obj/item/looking_for)
	if(internal_storage == looking_for)
		return ITEM_SLOT_DEX_STORAGE
	return ..()

/mob/living/simple_animal/hostile/guardian/dextrous/equip_to_slot(obj/item/equipped_item, slot)
	if(!..())
		return

	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			internal_storage = equipped_item
			update_inv_internal_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

/mob/living/simple_animal/hostile/guardian/dextrous/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/guardian/dextrous/getBeltSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/guardian/dextrous/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used?.hud_shown)
		internal_storage.screen_loc = ui_id
		client.screen += internal_storage

/mob/living/simple_animal/hostile/guardian/dextrous/regenerate_icons()
	..()
	update_inv_internal_storage()
