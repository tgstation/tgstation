/datum/hud/human
	inventory_slots = /datum/inventory_slot/human

/datum/hud/human/initialize_screen_objects()
	. = ..()
	var/atom/movable/screen/using
	// Static elements
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, HUD_GROUP_STATIC, ui_style, ui_human_language)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, HUD_GROUP_STATIC, ui_style, ui_human_navigate)
	add_screen_object(/atom/movable/screen/area_creator, HUD_MOB_AREA_CREATOR, HUD_GROUP_STATIC, ui_style, ui_human_area)
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/floor_changer/vertical, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_human_floor_changer)
	add_screen_object(/atom/movable/screen/mov_intent, HUD_MOB_MOVE_INTENT, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/drop, HUD_MOB_DROP, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 1))
	add_screen_object(/atom/movable/screen/human/toggle, HUD_HUMAN_TOGGLE_INVENTORY, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/rest, HUD_MOB_REST, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/sleep, HUD_MOB_SLEEP, HUD_GROUP_HOTKEYS, ui_style, ui_above_throw)
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_above_movement_top)
	add_screen_object(/atom/movable/screen/zone_sel, HUD_MOB_ZONE_SELECTOR, HUD_GROUP_STATIC, ui_style)
	build_hand_slots()

	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_2, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 2))
	using.icon_state = "act_swap"

	// Hotkey buttons
	add_screen_object(/atom/movable/screen/resist, HUD_MOB_RESIST, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/throw_catch, HUD_MOB_THROW, HUD_GROUP_HOTKEYS, ui_style)

	// Info
	add_screen_object(/atom/movable/screen/spacesuit, HUD_MOB_SPACESUIT, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/healthdoll/human, HUD_MOB_HEALTHDOLL, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/stamina, HUD_MOB_STAMINA, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/healths, HUD_MOB_HEALTH, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/hunger, HUD_MOB_HUNGER, HUD_GROUP_INFO)

/datum/hud/human/update_locked_slots()
	if(!mymob)
		return
	var/blocked_slots = NONE

	var/mob/living/carbon/human/human_mob = mymob
	if(istype(human_mob))
		blocked_slots |= human_mob.dna?.species?.no_equip_flags
		if((isnull(human_mob.w_uniform) || !(human_mob.w_uniform.item_flags & IN_INVENTORY)) && !HAS_TRAIT(human_mob, TRAIT_NO_JUMPSUIT))
			var/obj/item/bodypart/chest = human_mob.get_bodypart(BODY_ZONE_CHEST)
			if(isnull(chest) || IS_ORGANIC_LIMB(chest))
				blocked_slots |= ITEM_SLOT_ID|ITEM_SLOT_BELT
			var/obj/item/bodypart/left_leg = human_mob.get_bodypart(BODY_ZONE_L_LEG)
			if(isnull(left_leg) || IS_ORGANIC_LIMB(left_leg))
				blocked_slots |= ITEM_SLOT_LPOCKET
			var/obj/item/bodypart/right_leg = human_mob.get_bodypart(BODY_ZONE_R_LEG)
			if(isnull(right_leg) || IS_ORGANIC_LIMB(right_leg))
				blocked_slots |= ITEM_SLOT_RPOCKET
		if(isnull(human_mob.wear_suit) || !(human_mob.wear_suit.item_flags & IN_INVENTORY))
			blocked_slots |= ITEM_SLOT_SUITSTORE
		if(human_mob.num_hands <= 0)
			blocked_slots |= ITEM_SLOT_GLOVES
		if(human_mob.num_legs < 2) // update this when you can wear shoes on one foot
			blocked_slots |= ITEM_SLOT_FEET
		var/obj/item/bodypart/head/head = human_mob.get_bodypart(BODY_ZONE_HEAD)
		if(isnull(head))
			blocked_slots |= ITEM_SLOT_HEAD|ITEM_SLOT_EARS|ITEM_SLOT_EYES|ITEM_SLOT_MASK
		var/obj/item/organ/eyes/eyes = human_mob.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes?.no_glasses)
			blocked_slots |= ITEM_SLOT_EYES

	for(var/atom/movable/screen/inventory/inv in screen_objects)
		if(!inv.slot_id)
			continue
		inv.alpha = (blocked_slots & inv.slot_id) ? 128 : initial(inv.alpha)

/datum/hud/human/hidden_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			screenmob.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			screenmob.client.screen += H.gloves
		if(H.ears)
			H.ears.screen_loc = ui_ears
			screenmob.client.screen += H.ears
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			screenmob.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			screenmob.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			screenmob.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			screenmob.client.screen += H.wear_mask
		if(H.wear_neck)
			H.wear_neck.screen_loc = ui_neck
			screenmob.client.screen += H.wear_neck
		if(H.head)
			H.head.screen_loc = ui_head
			screenmob.client.screen += H.head
	else
		if(H.shoes)
			screenmob.client.screen -= H.shoes
		if(H.gloves)
			screenmob.client.screen -= H.gloves
		if(H.ears)
			screenmob.client.screen -= H.ears
		if(H.glasses)
			screenmob.client.screen -= H.glasses
		if(H.w_uniform)
			screenmob.client.screen -= H.w_uniform
		if(H.wear_suit)
			screenmob.client.screen -= H.wear_suit
		if(H.wear_mask)
			screenmob.client.screen -= H.wear_mask
		if(H.wear_neck)
			screenmob.client.screen -= H.wear_neck
		if(H.head)
			screenmob.client.screen -= H.head

/datum/hud/human/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	..()
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used)
		if(screenmob.hud_used.hud_shown)
			if(H.s_store)
				H.s_store.screen_loc = ui_sstore1
				screenmob.client.screen += H.s_store
			if(H.wear_id)
				H.wear_id.screen_loc = ui_id
				screenmob.client.screen += H.wear_id
			if(H.belt)
				H.belt.screen_loc = ui_belt
				screenmob.client.screen += H.belt
			if(H.back)
				H.back.screen_loc = ui_back
				screenmob.client.screen += H.back
			if(H.l_store)
				H.l_store.screen_loc = ui_storage1
				screenmob.client.screen += H.l_store
			if(H.r_store)
				H.r_store.screen_loc = ui_storage2
				screenmob.client.screen += H.r_store
		else
			if(H.s_store)
				screenmob.client.screen -= H.s_store
			if(H.wear_id)
				screenmob.client.screen -= H.wear_id
			if(H.belt)
				screenmob.client.screen -= H.belt
			if(H.back)
				screenmob.client.screen -= H.back
			if(H.l_store)
				screenmob.client.screen -= H.l_store
			if(H.r_store)
				screenmob.client.screen -= H.r_store

	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			screenmob.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			screenmob.client.screen -= I

/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.screen_groups[HUD_GROUP_HOTKEYS]
		hud_used.hotkey_ui_hidden = FALSE
	else
		client.screen -= hud_used.screen_groups[HUD_GROUP_HOTKEYS]
		hud_used.hotkey_ui_hidden = TRUE

/datum/inventory_slot/human
	abstract_type = /datum/inventory_slot/human

/datum/inventory_slot/human/uniform
	name = "uniform"
	slot_id = ITEM_SLOT_ICLOTHING
	icon_state = "uniform"
	icon_full = "template"
	screen_loc = ui_iclothing
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/suit
	name = "suit"
	slot_id = ITEM_SLOT_OCLOTHING
	icon_state = "suit"
	icon_full = "template"
	screen_loc = ui_oclothing
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/id
	name = "id"
	icon_state = "id"
	icon_full = "template_small"
	screen_loc = ui_id
	slot_id = ITEM_SLOT_ID

/datum/inventory_slot/human/mask
	name = "mask"
	icon_state = "mask"
	icon_full = "template"
	screen_loc = ui_mask
	slot_id = ITEM_SLOT_MASK
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/neck
	name = "neck"
	icon_state = "neck"
	icon_full = "template"
	screen_loc = ui_neck
	slot_id = ITEM_SLOT_NECK
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/back
	name = "back"
	icon_state = "back"
	icon_full = "template_small"
	screen_loc = ui_back
	slot_id = ITEM_SLOT_BACK

/datum/inventory_slot/human/l_pocket
	name = "left pocket"
	icon_state = "pocket"
	icon_full = "template_small"
	screen_loc = ui_storage1
	slot_id = ITEM_SLOT_LPOCKET

/datum/inventory_slot/human/l_pocket
	name = "right pocket"
	icon_state = "pocket"
	icon_full = "template_small"
	screen_loc = ui_storage2
	slot_id = ITEM_SLOT_RPOCKET

/datum/inventory_slot/human/l_pocket
	name = "suit storage"
	icon_state = "suit_storage"
	icon_full = "template"
	screen_loc = ui_sstore1
	slot_id = ITEM_SLOT_SUITSTORE

/datum/inventory_slot/human/l_pocket
	name = "gloves"
	icon_state = "gloves"
	icon_full = "template"
	screen_loc = ui_gloves
	slot_id = ITEM_SLOT_GLOVES
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/eyes
	name = "eyes"
	icon_state = "glasses"
	icon_full = "template"
	screen_loc = ui_glasses
	slot_id = ITEM_SLOT_EYES
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/ears
	name = "ears"
	icon_state = "ears"
	icon_full = "template"
	screen_loc = ui_ears
	slot_id = ITEM_SLOT_EARS
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/head
	name = "head"
	icon_state = "head"
	icon_full = "template"
	screen_loc = ui_head
	slot_id = ITEM_SLOT_HEAD
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/shoes
	name = "shoes"
	icon_state = "shoes"
	icon_full = "template"
	screen_loc = ui_shoes
	slot_id = ITEM_SLOT_FEET
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/belt
	name = "belt"
	icon_state = "belt"
	icon_full = "template_small"
	screen_loc = ui_belt
	slot_id = ITEM_SLOT_BELT
