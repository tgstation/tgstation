/obj/hud/proc/human_hud(var/ui_style='icons/mob/screen1_old.dmi')

	src.adding = list(  )
	src.other = list(  )
	src.vimpaired = list(  )
	src.darkMask = list(  )
	src.hotkeybuttons = list(  ) //These can be disabled for hotkey usersx

	src.g_dither = new src.h_type( src )
	src.g_dither.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.g_dither.name = "Mask"
	src.g_dither.icon = ui_style
	src.g_dither.icon_state = "dither12g"
	src.g_dither.layer = 18
	src.g_dither.mouse_opacity = 0

	src.alien_view = new src.h_type(src)
	src.alien_view.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.alien_view.name = "Alien"
	src.alien_view.icon = ui_style
	src.alien_view.icon_state = "alien"
	src.alien_view.layer = 18
	src.alien_view.mouse_opacity = 0

	src.blurry = new src.h_type( src )
	src.blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.blurry.name = "Blurry"
	src.blurry.icon = ui_style
	src.blurry.icon_state = "blurry"
	src.blurry.layer = 17
	src.blurry.mouse_opacity = 0

	src.druggy = new src.h_type( src )
	src.druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.druggy.name = "Druggy"
	src.druggy.icon = ui_style
	src.druggy.icon_state = "druggy"
	src.druggy.layer = 17
	src.druggy.mouse_opacity = 0

	var/obj/screen/using

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
	src.adding += using
*/

	using = new src.h_type( src )
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.hotkeybuttons += using

	using = new src.h_type( src )
	using.name = "i_clothing"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "center"
	using.screen_loc = ui_iclothing
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "o_clothing"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_oclothing
	using.layer = 19
	src.other += using

/*	using = new src.h_type( src )
	using.name = "headset"
	using.dir = SOUTHEAST
	using.icon_state = "equip"
	using.screen_loc = ui_headset
	using.layer = 19
	if(istype(mymob,/mob/living/carbon/monkey)) using.overlays += blocked
	src.other += using*/

	using = new src.h_type( src )
	using.name = "r_hand"
	using.dir = WEST
	using.icon = ui_style
	using.icon_state = "hand_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		using.icon_state = "hand_active"
	using.screen_loc = ui_rhand
	using.layer = 19
	src.r_hand_hud_object = using
	src.adding += using

	using = new src.h_type( src )
	using.name = "l_hand"
	using.dir = EAST
	using.icon = ui_style
	using.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		using.icon_state = "hand_active"
	using.screen_loc = ui_lhand
	using.layer = 19
	src.l_hand_hud_object = using
	src.adding += using

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

	using = new src.h_type( src )
	using.name = "id"
	using.dir = NORTH
	using.icon = ui_style
	using.icon_state = "id"
	using.screen_loc = ui_id
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "mask"
	using.dir = NORTH
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_mask
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "back"
	using.dir = NORTH
	using.icon = ui_style
	using.icon_state = "back"
	using.screen_loc = ui_back
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "storage1"
	using.icon = ui_style
	using.icon_state = "pocket"
	using.screen_loc = ui_storage1
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "storage2"
	using.icon = ui_style
	using.icon_state = "pocket"
	using.screen_loc = ui_storage2
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "suit storage"
	using.icon = ui_style
	using.dir = 8 //The sprite at dir=8 has the background whereas the others don't.
	using.icon_state = "belt"
	using.screen_loc = ui_sstore1
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = 19
	src.hotkeybuttons += using

	using = new src.h_type( src )
	using.name = "other"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_inventory
	using.layer = 20
	src.adding += using

	using = new src.h_type( src )
	using.name = "equip"
	using.icon = ui_style
	using.icon_state = "act_equip"
	using.screen_loc = ui_equip
	using.layer = 20
	src.adding += using

/*
	using = new src.h_type( src )
	using.name = "intent"
	using.icon_state = "intent"
	using.screen_loc = "15,15"
	using.layer = 20
	src.adding += using

	using = new src.h_type( src )
	using.name = "m_intent"
	using.icon_state = "move"
	using.screen_loc = "15,14"
	using.layer = 20
	src.adding += using
*/

	using = new src.h_type( src )
	using.name = "gloves"
	using.icon = ui_style
	using.icon_state = "gloves"
	using.screen_loc = ui_gloves
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "eyes"
	using.icon = ui_style
	using.icon_state = "glasses"
	using.screen_loc = ui_glasses
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "ears"
	using.icon = ui_style
	using.icon_state = "ears"
	using.screen_loc = ui_ears
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "head"
	using.icon = ui_style
	using.icon_state = "hair"
	using.screen_loc = ui_head
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "shoes"
	using.icon = ui_style
	using.icon_state = "shoes"
	using.screen_loc = ui_shoes
	using.layer = 19
	src.other += using

	using = new src.h_type( src )
	using.name = "belt"
	using.icon = ui_style
	using.icon_state = "belt"
	using.screen_loc = ui_belt
	using.layer = 19
	src.adding += using

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

	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "1,1 to 5,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "5,1 to 10,5"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "6,11 to 10,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "11,1 to 15,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using

	//welding mask dither
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "3,3 to 5,13"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "5,3 to 10,5"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "6,11 to 10,13"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "dither50"
	using.screen_loc = "11,3 to 13,13"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using

	//welding mask blackness
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "black"
	using.screen_loc = "1,1 to 15,2"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "black"
	using.screen_loc = "1,3 to 2,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "black"
	using.screen_loc = "14,3 to 15,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using
	using = new src.h_type( src )
	using.name = null
	using.icon = ui_style
	using.icon_state = "black"
	using.screen_loc = "3,14 to 13,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.darkMask += using

	mymob.throw_icon = new /obj/screen(null)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw
	src.hotkeybuttons += mymob.throw_icon

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


/*
	mymob.i_select = new /obj/screen( null )
	mymob.i_select.icon_state = "selector"
	mymob.i_select.name = "intent"
	mymob.i_select.screen_loc = "16:-11,15"

	mymob.m_select = new /obj/screen( null )
	mymob.m_select.icon_state = "selector"
	mymob.m_select.name = "moving"
	mymob.m_select.screen_loc = "16:-11,14"
*/

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

	mymob.nutrition_icon = new /obj/screen( null )
	mymob.nutrition_icon.icon = ui_style
	mymob.nutrition_icon.icon_state = "nutrition0"
	mymob.nutrition_icon.name = "nutrition"
	mymob.nutrition_icon.screen_loc = ui_nutrition

	mymob.pullin = new /obj/screen( null )
	mymob.pullin.icon = ui_style
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.mouse_opacity = 0
	mymob.blind.layer = 0

	mymob.damageoverlay = new /obj/screen( null )
	mymob.damageoverlay.icon = 'icons/mob/screen1_full.dmi'
	mymob.damageoverlay.icon_state = "oxydamageoverlay0"
	mymob.damageoverlay.name = "dmg"
	mymob.damageoverlay.screen_loc = "1,1"
	mymob.damageoverlay.mouse_opacity = 0
	mymob.damageoverlay.layer = 17

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
	mymob.rest.screen_loc = ui_rest
*/

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
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.screen = null

	//, mymob.i_select, mymob.m_select
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.nutrition_icon, mymob.pullin, mymob.blind, mymob.flash, mymob.damageoverlay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	inventory_shown = 0;

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

/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += src.hud_used.hotkeybuttons
		src.hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= src.hud_used.hotkeybuttons
		src.hud_used.hotkey_ui_hidden = 1



/*

Radar-related things

*/

/mob/living/carbon/human/proc/close_radar()
	radar_open = 0
	for(var/obj/screen/x in client.screen)
		if( (x.name == "radar" && x.icon == 'icons/misc/radar.dmi') || (x in radar_blips) )
			client.screen -= x
			del(x)

	place_radar_closed()

/mob/living/carbon/human/proc/place_radar_closed()
	var/obj/screen/closedradar = new()
	closedradar.icon = 'icons/misc/radar.dmi'
	closedradar.icon_state = "radarclosed"
	closedradar.screen_loc = "WEST,NORTH-1"
	closedradar.name = "radar closed"
	client.screen += closedradar

/mob/living/carbon/human/proc/start_radar()

	for(var/obj/screen/x in client.screen)
		if(x.name == "radar closed" && x.icon == 'icons/misc/radar.dmi')
			client.screen -= x
			del(x)

	var/obj/screen/cornerA = new()
	cornerA.icon = 'icons/misc/radar.dmi'
	cornerA.icon_state = "radar(1,1)"
	cornerA.screen_loc = "WEST,NORTH-2"
	cornerA.name = "radar"

	var/obj/screen/cornerB = new()
	cornerB.icon = 'icons/misc/radar.dmi'
	cornerB.icon_state = "radar(2,1)"
	cornerB.screen_loc = "WEST+1,NORTH-2"
	cornerB.name = "radar"

	var/obj/screen/cornerC = new()
	cornerC.icon = 'icons/misc/radar.dmi'
	cornerC.icon_state = "radar(1,2)"
	cornerC.screen_loc = "WEST,NORTH-1"
	cornerC.name = "radar"

	var/obj/screen/cornerD = new()
	cornerD.icon = 'icons/misc/radar.dmi'
	cornerD.icon_state = "radar(2,2)"
	cornerD.screen_loc = "WEST+1,NORTH-1"
	cornerD.name = "radar"

	client.screen += cornerA
	client.screen += cornerB
	client.screen += cornerC
	client.screen += cornerD

	radar_open = 1

	while(radar_open && (RADAR in augmentations))
		update_radar()
		sleep(6)

/mob/living/carbon/human/proc/update_radar()

	if(!client) return
	var/list/found_targets = list()

	var/max_dist = 29 // 29 tiles is the max distance

	// If the mob is inside a turf, set the center to the object they're in
	var/atom/distance_ref = src
	if(!isturf(src.loc))
		distance_ref = loc

	// Clear the radar_blips cache
	for(var/x in radar_blips)
		client.screen -= x
		del(x)
	radar_blips = list()

	var/starting_px = 3
	var/starting_py = 3

	for(var/mob/living/M in orange(max_dist, distance_ref))
		if(M.stat == 2) continue
		found_targets.Add(M)

	for(var/obj/effect/critter/C in orange(max_dist, distance_ref))
		if(!C.alive) continue
		found_targets.Add(C)

	for(var/obj/mecha/M in orange(max_dist, distance_ref))
		if(!M.occupant) continue
		found_targets.Add(M)

	for(var/obj/structure/closet/C in orange(max_dist, distance_ref))
		for(var/mob/living/M in C.contents)
			if(M.stat == 2) continue
			found_targets.Add(M)

	// Loop through all living mobs in a range.
	for(var/atom/A in found_targets)

		var/a_x = A.x
		var/a_y = A.y

		if(!isturf(A.loc))
			a_x = A.loc.x
			a_y = A.loc.y

		var/blip_x = max_dist + (-( distance_ref.x-a_x ) ) + starting_px
		var/blip_y = max_dist + (-( distance_ref.y-a_y ) ) + starting_py
		var/obj/screen/blip = new()
		blip.icon = 'icons/misc/radar.dmi'
		blip.name = "Blip"
		blip.layer = 21
		blip.screen_loc = "WEST:[blip_x-1],NORTH-2:[blip_y-1]" // offset -1 because the center of the blip is not at the bottomleft corner (14)

		if(istype(A, /mob/living))
			var/mob/living/M = A
			if(ishuman(M))
				if(M:wear_id)
					var/job = M:wear_id:GetJobName()
					if(job == "Security Officer")
						blip.icon_state = "secblip"
						blip.name = "Security Officer"
					else if(job == "Captain" || job == "Research Director" || job == "Chief Engineer" || job == "Chief Medical Officer" || job == "Head of Security" || job == "Head of Personnel")
						blip.icon_state = "headblip"
						blip.name = "Station Head"
					else
						blip.icon_state = "civblip"
						blip.name = "Civilian"
				else
					blip.icon_state = "civblip"
					blip.name = "Civilian"

			else if(issilicon(M))
				blip.icon_state = "roboblip"
				blip.name = "Robotic Organism"

			else
				blip.icon_state = "unknownblip"
				blip.name = "Unknown Organism"

		else if(istype(A, /obj/effect/critter))
			blip.icon_state = "unknownblip"
			blip.name = "Unknown Organism"

		else if(istype(A, /obj/mecha))
			blip.icon_state = "roboblip"
			blip.name = "Robotic Organism"

		radar_blips.Add(blip)
		client.screen += blip


/mob/living/carbon/human/update_action_buttons()
	var/num = 1
	if(!src.hud_used) return
	if(!src.client) return

	if(!hud_used.hud_shown)	//Hud toggled to minimal
		return

	src.client.screen -= src.hud_used.item_action_list
	hud_used.item_action_list = list()

	for(var/obj/item/I in src)
		if(I.icon_action_button)
			var/obj/screen/item_action/A = new(src.hud_used)
			A.icon = 'icons/mob/screen1_action.dmi'
			A.icon_state = I.icon_action_button
			if(I.action_button_name)
				A.name = I.action_button_name
			else
				A.name = "Use [I.name]"
			A.owner = I
			hud_used.item_action_list += A
			switch(num)
				if(1)
					A.screen_loc = ui_action_slot1
				if(2)
					A.screen_loc = ui_action_slot2
				if(3)
					A.screen_loc = ui_action_slot3
				if(4)
					A.screen_loc = ui_action_slot4
				if(5)
					A.screen_loc = ui_action_slot5
					break //5 slots available, so no more can be added.
			num++

	src.client.screen += src.hud_used.item_action_list