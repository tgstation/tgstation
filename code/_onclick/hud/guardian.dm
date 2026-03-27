/datum/hud/guardian
	ui_style = 'icons/hud/guardian.dmi'

/datum/hud/guardian/New(mob/living/basic/guardian/owner)
	..()
	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian(null, src)
	infodisplay += healths

/datum/hud/dextrous/guardian/New(mob/living/basic/guardian/owner) //for a dextrous guardian
	..()
	if(istype(owner, /mob/living/basic/guardian/dextrous))
		var/atom/movable/screen/inventory/inv_box
		inv_box = new /atom/movable/screen/inventory(null, src)
		inv_box.name = "internal storage"
		inv_box.icon = ui_style
		inv_box.icon_state = "suit_storage"
		inv_box.screen_loc = ui_back
		inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
		static_inventory += inv_box

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian(null, src)
	infodisplay += healths

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

/datum/action/cooldown/guardian
	button_icon = 'icons/hud/guardian.dmi'

/datum/action/cooldown/guardian/IsAvailable(feedback)
	. = ..()
	if(!.)
		return .
	return !!isguardian(owner)

/datum/action/cooldown/guardian/communicate
	name = "Communicate"
	desc = "Communicate telepathically with your user."
	button_icon_state = "communicate"
	default_button_position = GUARDIAN_COMMUNICATE_LOCATION

/datum/action/cooldown/guardian/communicate/Activate()
	astype(owner, /mob/living/basic/guardian)?.communicate()

/datum/action/cooldown/guardian/manifest
	name = "Manifest"
	desc = "Spring forth into battle!"
	button_icon_state = "manifest"
	default_button_position = GUARDIAN_MANIFEST_LOCATION

/datum/action/cooldown/guardian/manifest/Activate()
	astype(owner, /mob/living/basic/guardian)?.manifest()

/datum/action/cooldown/guardian/recall
	name = "Recall"
	desc = "Return to your user."
	button_icon_state = "recall"
	default_button_position = GUARDIAN_RECALL_LOCATION

/datum/action/cooldown/guardian/recall/Activate()
	astype(owner, /mob/living/basic/guardian)?.recall()

/datum/action/cooldown/guardian/toggle_light
	name = "Toggle Light"
	desc = "Glow like star dust."
	button_icon_state = "light"
	default_button_position = SCRN_OBJ_INSERT_FIRST

/datum/action/cooldown/guardian/toggle_light/Activate()
	astype(owner, /mob/living/basic/guardian)?.toggle_light()

/datum/action/cooldown/guardian/toggle_mode
	name = "Toggle Mode"
	desc = "Switch between ability modes."
	button_icon_state = "toggle"
	default_button_position = GUARDIAN_TOGGLE_LOCATION

/datum/action/cooldown/guardian/toggle_mode/Activate()
	astype(owner, /mob/living/basic/guardian)?.toggle_modes()

/datum/action/cooldown/guardian/toggle_mode/assassin
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."
	button_icon_state = "stealth"
	transparent_when_unavailable = TRUE

/datum/action/cooldown/guardian/toggle_mode/assassin/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return owner.has_status_effect(/datum/status_effect/guardian_stealth)

/datum/action/cooldown/guardian/toggle_mode/gases
	name = "Toggle Gas"
	desc = "Switch between possible gases."
	button_icon_state = "gases"
