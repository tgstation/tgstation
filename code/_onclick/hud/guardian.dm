/datum/hud/guardian
	ui_style = 'icons/hud/guardian.dmi'

/datum/hud/guardian/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/guardian/manifest, HUD_GUARDIAN_MANIFEST, ui_loc = ui_hand_position(RIGHT_HANDS))
	add_screen_object(/atom/movable/screen/guardian/recall, HUD_GUARDIAN_RECALL, ui_loc = ui_hand_position(LEFT_HANDS))
	add_screen_object(/atom/movable/screen/guardian/toggle_light, HUD_GUARDIAN_LIGHT)
	add_screen_object(/atom/movable/screen/guardian/communicate, HUD_GUARDIAN_COMMUNICATE)

	add_screen_object(/atom/movable/screen/healths/guardian, HUD_MOB_HEALTH, HUD_GROUP_INFO)

	var/mob/living/basic/guardian/owner = mymob
	if (istype(owner))
		add_screen_object(owner.toggle_button_type, HUD_GUARDIAN_TOGGLE, ui_loc = ui_storage1)

/datum/hud/dextrous/guardian/initialize_screen_objects()
	. = ..()
	if(istype(mymob, /mob/living/basic/guardian/dextrous))
		inventory_slots = list(/datum/inventory_slot/guardian_storage)
		add_screen_object(/atom/movable/screen/guardian/communicate, HUD_GUARDIAN_COMMUNICATE, ui_loc = ui_sstore1)
	else
		add_screen_object(/atom/movable/screen/guardian/communicate, HUD_GUARDIAN_COMMUNICATE, ui_loc = ui_id)

	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/guardian/manifest, HUD_GUARDIAN_MANIFEST, ui_loc = ui_belt)
	add_screen_object(/atom/movable/screen/guardian/recall, HUD_GUARDIAN_RECALL, ui_loc = ui_back)
	add_screen_object(/atom/movable/screen/guardian/toggle_light, HUD_GUARDIAN_LIGHT)

	add_screen_object(/atom/movable/screen/healths/guardian, HUD_MOB_HEALTH, HUD_GROUP_INFO)

	var/mob/living/basic/guardian/owner = mymob
	if (istype(owner))
		add_screen_object(owner.toggle_button_type, HUD_GUARDIAN_TOGGLE, ui_loc = ui_storage2)

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return

	if(!istype(mymob, /mob/living/basic/guardian/dextrous))
		return ..()

	var/mob/living/basic/guardian/dextrous/dex_guardian = mymob
	if(hud_shown)
		if(dex_guardian.internal_storage)
			dex_guardian.internal_storage.screen_loc = ui_id
			dex_guardian.client.screen += dex_guardian.internal_storage
	else
		if(dex_guardian.internal_storage)
			dex_guardian.internal_storage.screen_loc = null
	return ..()

/datum/inventory_slot/guardian_storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_DEX_STORAGE
	screen_loc = ui_id
