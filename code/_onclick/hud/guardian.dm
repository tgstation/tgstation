/datum/hud/guardian
	ui_style = 'icons/hud/guardian.dmi'

/datum/hud/guardian/New(mob/living/basic/guardian/owner)
	..()
	var/atom/movable/screen/using

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian(null, src)
	infodisplay += healths

	using = new owner.toggle_button_type(null, src)
	using.screen_loc = ui_storage1
	static_inventory += using

/datum/hud/dextrous/guardian/New(mob/living/basic/guardian/owner) //for a dextrous guardian
	..()
	var/atom/movable/screen/using
	if(istype(owner, /mob/living/basic/guardian/dextrous))
		var/atom/movable/screen/inventory/inv_box

		inv_box = new /atom/movable/screen/inventory(null, src)
		inv_box.name = "internal storage"
		inv_box.icon = ui_style
		inv_box.icon_state = "suit_storage"
		inv_box.screen_loc = ui_id
		inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
		static_inventory += inv_box

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian(null, src)
	infodisplay += healths

	using = new owner.toggle_button_type(null, src)
	using.screen_loc = ui_storage2
	static_inventory += using

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return
	if(istype(mymob, /mob/living/basic/guardian/dextrous))
		var/mob/living/basic/guardian/dextrous/dex_guardian = mymob

		if(hud_shown)
			if(dex_guardian.internal_storage)
				dex_guardian.internal_storage.screen_loc = ui_id
				dex_guardian.client.screen += dex_guardian.internal_storage
		else
			if(dex_guardian.internal_storage)
				dex_guardian.internal_storage.screen_loc = null

	..()

/atom/movable/screen/guardian
	icon = 'icons/hud/guardian.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/guardian/toggle_mode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/toggle_mode/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.toggle_modes()

/atom/movable/screen/guardian/toggle_mode/inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/atom/movable/screen/guardian/toggle_mode/assassin
	icon_state = "stealth"
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."

/atom/movable/screen/guardian/toggle_mode/gases
	icon_state = "gases"
	name = "Toggle Gas"
	desc = "Switch between possible gases."

/datum/action/innate/guardian
	button_icon = 'icons/hud/guardian.dmi'

/datum/action/innate/guardian/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	return !!isguardian(owner)

#define GUARDIAN_COMMUNICATE_LOCATION "CENTER+-2:16,SOUTH+0:5"
#define GUARDIAN_MANIFEST_LOCATION "CENTER+-1:16,SOUTH+0:5"
#define GUARDIAN_RECALL_LOCATION "CENTER+0:16,SOUTH+0:5"

/datum/action/innate/guardian/communicate
	name = "Communicate"
	button_icon_state = "communicate"
	desc = "Communicate telepathically with your user."
	default_button_position = GUARDIAN_COMMUNICATE_LOCATION

/datum/action/innate/guardian/communicate/Activate()
	astype(owner, /mob/living/basic/guardian)?.communicate()

/datum/action/innate/guardian/manifest
	name = "Manifest"
	desc = "Spring forth into battle!"
	button_icon_state = "manifest"
	default_button_position = GUARDIAN_MANIFEST_LOCATION

/datum/action/innate/guardian/manifest/Activate()
	astype(owner, /mob/living/basic/guardian)?.manifest()

/datum/action/innate/guardian/recall
	name = "Recall"
	desc = "Return to your user."
	button_icon_state = "recall"
	default_button_position = GUARDIAN_RECALL_LOCATION

/datum/action/innate/guardian/recall/Activate()
	astype(owner, /mob/living/basic/guardian)?.recall()

/datum/action/cooldown/guardian/toggle_light
	name = "Toggle Light"
	desc = "Glow like star dust."
	button_icon_state = "light"

/datum/action/cooldown/guardian/toggle_light/Activate()
	astype(owner, /mob/living/basic/guardian)?.toggle_light()

#undef GUARDIAN_COMMUNICATE_LOCATION
#undef GUARDIAN_MANIFEST_LOCATION
#undef GUARDIAN_RECALL_LOCATION
