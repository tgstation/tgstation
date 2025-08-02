/// Dextrous guardians have some of the most powerful abilities of all: hands and pockets
/mob/living/basic/guardian/dextrous
	guardian_type = GUARDIAN_DEXTROUS
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>dextrous</b> type you can hold items, store an item within yourself, and have medium damage resistance, but do low damage on attacks. Recalling and leashing will force you to drop unstored items!")
	creator_name = "Dextrous"
	creator_desc = "Does low damage on attack, but is capable of holding items and storing a single item within it. It will drop items held in its hands when it recalls, but it will retain the stored item."
	creator_icon = "dextrous"
	hud_type = /datum/hud/dextrous/guardian
	held_items = list(null, null)
	/// An internal pocket we can put stuff in
	var/obj/item/internal_storage

/mob/living/basic/guardian/dextrous/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	AddElement(/datum/element/dextrous, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/personal_crafting)
	AddComponent(/datum/component/basic_inhands)

/mob/living/basic/guardian/dextrous/death(gibbed)
	dropItemToGround(internal_storage)
	return ..()

/mob/living/basic/guardian/dextrous/examine(mob/user)
	. = ..()
	if(isnull(internal_storage) || (internal_storage.item_flags & ABSTRACT))
		return
	. += span_info("It is holding [internal_storage.examine_title(user)] in its internal storage.")

/mob/living/basic/guardian/dextrous/recall_effects()
	. = ..()
	drop_all_held_items()

// Bullshit related to having a fake pocket begins here

/mob/living/basic/guardian/dextrous/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..()
	if (!.)
		return FALSE
	update_held_items()
	if(item_dropping == internal_storage)
		internal_storage = null
		update_inv_internal_storage()
	return TRUE

/mob/living/basic/guardian/dextrous/can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(slot != ITEM_SLOT_DEX_STORAGE)
		return FALSE
	return isnull(internal_storage)

/mob/living/basic/guardian/dextrous/get_item_by_slot(slot_id)
	if(slot_id == ITEM_SLOT_DEX_STORAGE)
		return internal_storage
	return ..()

/mob/living/basic/guardian/dextrous/get_slot_by_item(obj/item/looking_for)
	if(internal_storage == looking_for)
		return ITEM_SLOT_DEX_STORAGE
	return ..()

/mob/living/basic/guardian/dextrous/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if (slot != ITEM_SLOT_DEX_STORAGE)
		to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
		return FALSE

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null
	update_held_items()

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null // will get moved if inventory is visible
	equipping.forceMove(src)
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)

	internal_storage = equipping
	update_inv_internal_storage()

	equipping.on_equipped(src, slot)
	return TRUE

/mob/living/basic/guardian/dextrous/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/basic/guardian/dextrous/proc/update_inv_internal_storage()
	if(isnull(internal_storage) || isnull(client) || !hud_used?.hud_shown)
		return
	internal_storage.screen_loc = ui_id
	client.screen += internal_storage

/mob/living/basic/guardian/dextrous/regenerate_icons()
	update_inv_internal_storage()
