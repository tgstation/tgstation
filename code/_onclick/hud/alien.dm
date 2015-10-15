/obj/screen/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/obj/screen/alien/leap/Click()
	if(istype(usr, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/obj/screen/alien/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"

/obj/screen/alien/nightvision/Click()
	var/mob/living/carbon/alien/A = usr
	var/obj/effect/proc_holder/alien/nightvisiontoggle/T = locate() in A.abilities
	if(T)
		T.fire(A)


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

	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	adding += using
	action_intent = using

	if(istype(mymob, /mob/living/carbon/alien/humanoid/hunter))
		mymob.leap_icon = new /obj/screen/alien/leap()
		mymob.leap_icon.screen_loc = ui_alien_storage_r
		adding += mymob.leap_icon

	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == RUN ? "running" : (WALK ? "walking" : "sprinting"))
	using.screen_loc = ui_movi
	adding += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_drop_throw
	adding += using

	using = new /obj/screen/resist()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.screen_loc = ui_pull_resist
	adding += using

	mymob.throw_icon = new /obj/screen/throw_catch()
	mymob.throw_icon.icon = 'icons/mob/screen_alien.dmi'
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

//begin indicators

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	nightvisionicon = new /obj/screen/alien/nightvision()
	nightvisionicon.screen_loc = ui_alien_nightvision

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
	mymob.blind.mouse_opacity = 0

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_gen.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel/alien()
	mymob.zone_sel.icon = 'icons/mob/screen_alien.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.healths, nightvisionicon, alien_plasma_display, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other
	mymob.client.screen += mymob.client.void