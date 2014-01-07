/datum/hud/proc/alien_hud()
	adding = list()
	other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

//equippable shit

//hands
	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = 19
	r_hand_hud_object = inv_box
	inv_box.slot_id = slot_r_hand
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.layer = 19
	inv_box.slot_id = slot_l_hand
	l_hand_hud_object = inv_box
	adding += inv_box

//pocket 1
	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_alien_storage_l
	inv_box.slot_id = slot_l_store
	inv_box.layer = 19
	adding += inv_box

//pocket 2
	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_alien_storage_r
	inv_box.slot_id = slot_r_store
	inv_box.layer = 19
	adding += inv_box

//begin buttons

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	adding += using

	using = new /obj/screen()
	using.name = "act_intent"
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = 20
	adding += using
	action_intent = using

	using = new /obj/screen()
	using.name = "mov_intent"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	adding += using
	move_intent = using

	using = new /obj/screen()
	using.name = "drop"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	adding += using

	using = new /obj/screen()
	using.name = "resist"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	adding += using

	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen_alien.dmi'
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw/catch"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

//begin indicators

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen_alien.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_alien_oxygen

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = 'icons/mob/screen_alien.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_alien_toxin

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen_alien.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_alien_fire

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	alien_plasma_display = new /obj/screen()
	alien_plasma_display.icon = 'icons/mob/screen_gen.dmi'
	alien_plasma_display.icon_state = "power_display2"
	alien_plasma_display.name = "plasma stored"
	alien_plasma_display.screen_loc = ui_alienplasmadisplay

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_alien.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel/alien()
	mymob.zone_sel.icon = 'icons/mob/screen_alien.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.fire, mymob.healths, alien_plasma_display, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other

