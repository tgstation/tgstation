
/datum/hud/guardian/New(mob/living/simple_animal/hostile/guardian/owner)
	..()
	var/obj/screen/using

	healths = new /obj/screen/healths/guardian()
	infodisplay += healths

	using = new /obj/screen/guardian/Manifest()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/guardian/Recall()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /obj/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/guardian/Communicate()
	using.screen_loc = ui_back
	static_inventory += using


/mob/living/simple_animal/hostile/guardian/create_mob_hud()
	if(client && !hud_used)
		if(dextrous)
			..()
		else
			hud_used = new /datum/hud/guardian(src, ui_style2icon(client.prefs.UI_style))

/datum/hud/dextrous/guardian/New(mob/living/simple_animal/hostile/guardian/owner, ui_style = 'icons/mob/screen_midnight.dmi') //for a dextrous guardian
	..()
	var/obj/screen/using
	if(istype(owner, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/obj/screen/inventory/inv_box

		inv_box = new /obj/screen/inventory()
		inv_box.name = "internal storage"
		inv_box.icon = ui_style
		inv_box.icon_state = "suit_storage"
		inv_box.screen_loc = ui_id
		inv_box.slot_id = slot_generic_dextrous_storage
		static_inventory += inv_box

		using = new /obj/screen/guardian/Communicate()
		using.screen_loc = ui_sstore1
		static_inventory += using

	else

		using = new /obj/screen/guardian/Communicate()
		using.screen_loc = ui_id
		static_inventory += using

	healths = new /obj/screen/healths/guardian()
	infodisplay += healths

	using = new /obj/screen/guardian/Manifest()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/guardian/Recall()
	using.screen_loc = ui_back
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage2
	static_inventory += using

	using = new /obj/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	static_inventory += using

/datum/hud/dextrous/guardian/persistent_inventory_update()
	if(!mymob)
		return
	if(istype(mymob, /mob/living/simple_animal/hostile/guardian/dextrous))
		var/mob/living/simple_animal/hostile/guardian/dextrous/D = mymob

		if(hud_shown)
			if(D.internal_storage)
				D.internal_storage.screen_loc = ui_id
				D.client.screen += D.internal_storage
		else
			if(D.internal_storage)
				D.internal_storage.screen_loc = null

	..()

/obj/screen/guardian
	icon = 'icons/mob/guardian.dmi'

/obj/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/obj/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Manifest()


/obj/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/obj/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/obj/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/obj/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/obj/screen/guardian/ToggleMode/Inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/obj/screen/guardian/ToggleMode/Assassin
	icon_state = "stealth"
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."

/obj/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/obj/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/obj/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/obj/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
