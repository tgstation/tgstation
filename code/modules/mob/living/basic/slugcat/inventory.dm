/datum/hud/dextrous/slugcat/New(mob/owner)
	..()
	var/atom/movable/screen/inventory/inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "back (for spears)"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
// inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
	static_inventory += inv_box

/datum/hud/dextrous/slugcat/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/basic/slugcat/slugcat = mymob

	if(hud_shown)
		if(!isnull(slugcat.internal_storage))
			slugcat.internal_storage.screen_loc = ui_drone_storage
			slugcat.client.screen += slugcat.internal_storage
	else
		slugcat.internal_storage?.screen_loc = null
	..()

/mob/living/basic/slugcat/proc/apply_overlay(cache_index)
	if((. = slugcat_overlays[cache_index]))
		add_overlay(.)

/mob/living/basic/slugcat/proc/remove_overlay(cache_index)
	var/overlay = slugcat_overlays[cache_index]
	if(overlay)
		cut_overlay(overlay)
		slugcat_overlays[cache_index] = null

/mob/living/basic/slugcat/update_worn_back(update_obscured = TRUE)
	remove_overlay(DRONE_HEAD_LAYER)

	if(internal_storage)
		var/used_back_icon = 'icons/mob/clothing/back.dmi'
		var/mutable_appearance/back_overlay = internal_storage.build_worn_icon(default_layer = DRONE_HEAD_LAYER, default_icon_file = used_back_icon)
		back_overlay.pixel_z -= 6

		slugcat_overlays[DRONE_HEAD_LAYER] = back_overlay

	apply_overlay(DRONE_HEAD_LAYER)

/mob/living/basic/slugcat/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	. = ..()
	if (!.)
		return FALSE
	update_held_items()
	if(item_dropping == internal_storage)
		internal_storage = null
		update_inv_internal_storage()
		update_worn_back()
	return TRUE

/mob/living/basic/slugcat/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(slot != ITEM_SLOT_DEX_STORAGE)
		return FALSE
	if(!(item.slot_flags & ITEM_SLOT_BACK))
		return FALSE
	if((istype (item, /obj/item/storage)) || (istype (item, /obj/item/mod)))
		return FALSE
	return isnull(internal_storage)

/mob/living/basic/slugcat/get_item_by_slot(slot_id)
	if(slot_id == ITEM_SLOT_DEX_STORAGE)
		return internal_storage
	return ..()

/mob/living/basic/slugcat/get_slot_by_item(obj/item/looking_for)
	if(internal_storage == looking_for)
		return ITEM_SLOT_DEX_STORAGE
	return ..()

/mob/living/basic/slugcat/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
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
	update_worn_back()

	equipping.on_equipped(src, slot)
	return TRUE

/mob/living/basic/slugcat/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/basic/slugcat/proc/update_inv_internal_storage()
	if(isnull(internal_storage) || isnull(client) || !hud_used?.hud_shown)
		return
	internal_storage.screen_loc = ui_drone_storage
	client.screen += internal_storage

/mob/living/basic/slugcat/regenerate_icons()
	update_inv_internal_storage()

/mob/living/basic/slugcat/death(gibbed)
	..(gibbed)
	if(internal_storage)
		dropItemToGround(internal_storage)
