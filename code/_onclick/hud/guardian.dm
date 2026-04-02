/datum/hud/guardian/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, 'icons/hud/guardian.dmi')
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_below_throw)
	add_screen_object(/atom/movable/screen/healths/guardian, HUD_MOB_HEALTH, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style, ui_loc = ui_zonesel)

///Dextrous subtype for only dextrous holoparasites. Can hold things hence the inventory slot.
/datum/hud/dextrous/guardian
	inventory_slots = list(/datum/inventory_slot/guardian_storage)

/datum/hud/dextrous/guardian/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/healths/guardian, HUD_MOB_HEALTH, HUD_GROUP_INFO)

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return

	if(!istype(mymob, /mob/living/basic/guardian/dextrous))
		return ..()

	var/mob/living/basic/guardian/dextrous/dex_guardian = mymob
	if(hud_shown)
		if(dex_guardian.internal_storage)
			dex_guardian.internal_storage.screen_loc = ui_back
			dex_guardian.client.screen += dex_guardian.internal_storage
	else
		if(dex_guardian.internal_storage)
			dex_guardian.internal_storage.screen_loc = null
	return ..()

/datum/inventory_slot/guardian_storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_DEX_STORAGE
	screen_loc = ui_back

