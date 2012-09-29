/datum/hud/proc/monkey_hud(var/ui_style='icons/mob/screen1_old.dmi')

	src.adding = list(  )
	src.other = list(  )

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new /obj/screen( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	using = new /obj/screen( src )
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.adding += using

	inv_box = new /obj/screen/inventory( src )
	inv_box.name = "r_hand"
	inv_box.dir = WEST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /obj/screen/inventory( src )
	inv_box.name = "l_hand"
	inv_box.dir = EAST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /obj/screen( src )
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	src.adding += using

	using = new /obj/screen( src )
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	src.adding += using

	inv_box = new /obj/screen/inventory( src )
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = 19
	src.adding += inv_box

	inv_box = new /obj/screen/inventory( src )
	inv_box.name = "back"
	inv_box.dir = NORTHEAST
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = 19
	src.adding += inv_box

	mymob.throw_icon = new /obj/screen(null)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.oxygen = new /obj/screen( null )
	mymob.oxygen.icon = ui_style
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.pressure = new /obj/screen( null )
	mymob.pressure.icon = ui_style
	mymob.pressure.icon_state = "pressure0"
	mymob.pressure.name = "pressure"
	mymob.pressure.screen_loc = ui_pressure

	mymob.toxin = new /obj/screen( null )
	mymob.toxin.icon = ui_style
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = new /obj/screen( null )
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = new /obj/screen( null )
	mymob.fire.icon = ui_style
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = new /obj/screen( null )
	mymob.bodytemp.icon = ui_style
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = new /obj/screen( null )
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen( null )
	mymob.pullin.icon = ui_style
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	mymob.flash = new /obj/screen( null )
	mymob.flash.icon = ui_style
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

	return

