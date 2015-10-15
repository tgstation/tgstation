/datum/hud/proc/monkey_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	adding = list()
	other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent()
	using.icon = ui_style
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	adding += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == RUN ? "running" : (WALK ? "walking" : "sprinting"))
	using.screen_loc = ui_movi
	adding += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	r_hand_hud_object = inv_box
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	l_hand_hud_object = inv_box
	adding += inv_box

	using = new /obj/screen()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"	//extra wide!
	using.screen_loc = ui_swaphand1
	using.layer = 19
	adding += using

	using = new /obj/screen()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	adding += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = 19
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_monkey_head
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = 19
	adding += inv_box

	mymob.throw_icon = new /obj/screen/throw_catch()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.internals = new /obj/screen/internals()
	mymob.internals.screen_loc = ui_internal

	mymob.healths = new /obj/screen()
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

	lingchemdisplay = new /obj/screen/ling/chems()
	lingchemdisplay.screen_loc = ui_lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	lingstingdisplay.screen_loc = ui_lingstingdisplay

	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.damageoverlay = new /obj/screen()
	mymob.damageoverlay.icon = 'icons/mob/screen_full.dmi'
	mymob.damageoverlay.icon_state = "oxydamageoverlay0"
	mymob.damageoverlay.name = "dmg"
	mymob.damageoverlay.blend_mode = BLEND_MULTIPLY
	mymob.damageoverlay.screen_loc = "CENTER-7,CENTER-7"
	mymob.damageoverlay.mouse_opacity = 0
	mymob.damageoverlay.layer = 18.1 //The black screen overlay sets layer to 18 to display it, this one has to be just on top.

	mymob.flash = new /obj/screen()
	mymob.flash.icon = 'icons/mob/screen_gen.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.update_icon()

	mymob.client.screen = list()

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_pull_resist
	adding += using

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.pullin, mymob.blind, mymob.flash, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other
	mymob.client.screen += mymob.client.void