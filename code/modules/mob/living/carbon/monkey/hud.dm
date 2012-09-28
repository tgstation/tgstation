/datum/hud/proc/monkey_hud(var/ui_style='icons/mob/screen1_old.dmi')

	//ui_style='icons/mob/screen1_old.dmi' //Overriding the parameter. Only this UI style is acceptable with the 'sleek' layout.

	src.adding = list(  )
	src.other = list(  )

	//var/icon/blocked = icon(ui_style,"blocked")

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new src.h_type( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new src.h_type( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

/*
	using = new src.h_type(src) //Right hud bar
	using.dir = SOUTH
	using.icon = ui_style
	using.screen_loc = "EAST+1,SOUTH to EAST+1,NORTH"
	using.layer = 19
	src.adding += using

	using = new src.h_type(src) //Lower hud bar
	using.dir = EAST
	using.icon = ui_style
	using.screen_loc = "WEST,SOUTH-1 to EAST,SOUTH-1"
	using.layer = 19
	src.adding += using

	using = new src.h_type(src) //Corner Button
	using.dir = NORTHWEST
	using.icon = ui_style
	using.screen_loc = "EAST+1,SOUTH-1"
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "arrowleft"
	using.icon = ui_style
	using.icon_state = "s_arrow"
	using.dir = WEST
	using.screen_loc = ui_iarrowleft
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "arrowright"
	using.icon = ui_style
	using.icon_state = "s_arrow"
	using.dir = EAST
	using.screen_loc = ui_iarrowright
	using.layer = 19
	src.adding += using*/

	using = new src.h_type( src )
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.adding += using
/*
	using = new src.h_type( src )
	using.name = "i_clothing"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "center"
	using.screen_loc = ui_iclothing
	using.layer = 19
	using.overlays += blocked
	src.adding += using

	using = new src.h_type( src )
	using.name = "o_clothing"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_oclothing
	using.layer = 19
	using.overlays += blocked
	src.adding += using
*/
/*	using = new src.h_type( src )
	using.name = "headset"
	using.dir = SOUTHEAST
	using.icon_state = "equip"
	using.screen_loc = ui_headset
	using.layer = 19
	if(istype(mymob,/mob/living/carbon/monkey)) using.overlays += blocked
	src.other += using*/

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

	using = new src.h_type( src )
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	src.adding += using
/*
	using = new src.h_type( src )
	using.name = "id"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_id
	using.layer = 19
	using.overlays += blocked
	src.adding += using
*/

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
/*
	using = new src.h_type( src )
	using.name = "storage1"
	using.icon = ui_style
	using.icon_state = "pocket"
	using.screen_loc = ui_storage1
	using.layer = 19
	using.overlays += blocked
	src.adding += using

	using = new src.h_type( src )
	using.name = "storage2"
	using.icon = ui_style
	using.icon_state = "pocket"
	using.screen_loc = ui_storage2
	using.layer = 19
	using.overlays += blocked
	src.adding += using
	using = new src.h_type( src )
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_resist
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "other"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_shoes
	using.layer = 20
	src.adding += using

	using = new src.h_type( src )
	using.name = "gloves"
	using.icon = ui_style
	using.icon_state = "gloves"
	using.screen_loc = ui_gloves
	using.layer = 19
	using.overlays += blocked
	src.other += using

	using = new src.h_type( src )
	using.name = "eyes"
	using.icon = ui_style
	using.icon_state = "glasses"
	using.screen_loc = ui_glasses
	using.layer = 19
	using.overlays += blocked
	src.other += using

	using = new src.h_type( src )
	using.name = "ears"
	using.icon = ui_style
	using.icon_state = "ears"
	using.screen_loc = ui_ears
	using.layer = 19
	using.overlays += blocked
	src.other += using

	using = new src.h_type( src )
	using.name = "head"
	using.icon = ui_style
	using.icon_state = "hair"
	using.screen_loc = ui_head
	using.layer = 19
	using.overlays += blocked
	src.adding += using

	using = new src.h_type( src )
	using.name = "shoes"
	using.icon = ui_style
	using.icon_state = "shoes"
	using.screen_loc = ui_shoes
	using.layer = 19
	using.overlays += blocked
	src.other += using

	using = new src.h_type( src )
	using.name = "belt"
	using.icon = ui_style
	using.icon_state = "belt"
	using.screen_loc = ui_belt
	using.layer = 19
	using.overlays += blocked
	src.adding += using
*/

/*
	using = new src.h_type( src )
	using.name = "grab"
	using.icon_state = "grab"
	using.screen_loc = "12:-11,15"
	using.layer = 19
	src.intents += using
	//ICONS
	using = new src.h_type( src )
	using.name = "hurt"
	using.icon_state = "harm"
	using.screen_loc = "15:-11,15"
	using.layer = 19
	src.intents += using
	src.m_ints += using

	using = new src.h_type( src )
	using.name = "disarm"
	using.icon_state = "disarm"
	using.screen_loc = "14:-10,15"
	using.layer = 19
	src.intents += using

	using = new src.h_type( src )
	using.name = "help"
	using.icon_state = "help"
	using.screen_loc = "13:-10,15"
	using.layer = 19
	src.intents += using
	src.m_ints += using

	using = new src.h_type( src )
	using.name = "face"
	using.icon_state = "facing"
	using.screen_loc = "15:-11,14"
	using.layer = 19
	src.mov_int += using

	using = new src.h_type( src )
	using.name = "walk"
	using.icon_state = "walking"
	using.screen_loc = "14:-11,14"
	using.layer = 19
	src.mov_int += using

	using = new src.h_type( src )
	using.name = "run"
	using.icon_state = "running"
	using.screen_loc = "13:-11,14"
	using.layer = 19
	src.mov_int += using
*/

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

/*
	mymob.hands = new /obj/screen( null )
	mymob.hands.icon = ui_style
	mymob.hands.icon_state = "hand"
	mymob.hands.name = "hand"
	mymob.hands.screen_loc = ui_hand
	mymob.hands.dir = NORTH

	mymob.sleep = new /obj/screen( null )
	mymob.sleep.icon = ui_style
	mymob.sleep.icon_state = "sleep0"
	mymob.sleep.name = "sleep"
	mymob.sleep.screen_loc = ui_sleep

	mymob.rest = new /obj/screen( null )
	mymob.rest.icon = ui_style
	mymob.rest.icon_state = "rest0"
	mymob.rest.name = "rest"
	mymob.rest.screen_loc = ui_rest*/

	/*/Monkey blockers

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_ears
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_belt
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_shoes
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_storage2
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_glasses
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_gloves
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_storage1
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_headset
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_oclothing
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_iclothing
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_id
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_head
	using.layer = 20
	src.mon_blo += using
//Monkey blockers
*/

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.screen = null

	//, mymob.i_select, mymob.m_select
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

	//if(istype(mymob,/mob/living/carbon/monkey)) mymob.client.screen += src.mon_blo

	return

	/*
	using = new src.h_type( src )
	using.dir = WEST
	using.screen_loc = "1,3 to 2,3"
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.dir = NORTHEAST
	using.screen_loc = "3,3"
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.dir = NORTH
	using.screen_loc = "3,2"
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.dir = SOUTHEAST
	using.screen_loc = "3,1"
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.dir = SOUTHWEST
	using.screen_loc = "1,1 to 2,2"
	using.layer = 19
	src.adding += using
	*/