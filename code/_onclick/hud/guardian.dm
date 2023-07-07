/datum/hud/guardian
	ui_style = 'icons/hud/guardian.dmi'

/datum/hud/guardian/New(mob/living/simple_animal/hostile/guardian/owner)
	..()
	var/atom/movable/screen/using

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/guardian/manifest()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/recall()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/toggle_light()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/communicate()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

/datum/hud/dextrous/guardian/New(mob/living/simple_animal/hostile/guardian/owner) //for a dextrous guardian
	..()
	var/atom/movable/screen/using
	if(istype(owner, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/atom/movable/screen/inventory/inv_box

		inv_box = new /atom/movable/screen/inventory()
		inv_box.name = "internal storage"
		inv_box.icon = ui_style
		inv_box.icon_state = "suit_storage"
		inv_box.screen_loc = ui_id
		inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
		inv_box.hud = src
		static_inventory += inv_box

		using = new /atom/movable/screen/guardian/communicate()
		using.screen_loc = ui_sstore1
		using.hud = src
		static_inventory += using

	else

		using = new /atom/movable/screen/guardian/communicate()
		using.screen_loc = ui_id
		using.hud = src
		static_inventory += using

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/guardian/manifest()
	using.screen_loc = ui_belt
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/recall()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage2
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/guardian/toggle_light()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return
	if(istype(mymob, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/mob/living/simple_animal/hostile/guardian/dextrous/dex_guardian = mymob

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

/atom/movable/screen/guardian/manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/atom/movable/screen/guardian/manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/user = usr
		user.manifest()


/atom/movable/screen/guardian/recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/atom/movable/screen/guardian/recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/user = usr
		user.recall()

/atom/movable/screen/guardian/toggle_mode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/toggle_mode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/user = usr
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

/atom/movable/screen/guardian/communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/atom/movable/screen/guardian/communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/user = usr
		user.communicate()


/atom/movable/screen/guardian/toggle_light
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/atom/movable/screen/guardian/toggle_light/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/user = usr
		user.toggle_light()
