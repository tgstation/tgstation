/obj/hud/proc/alien_hud()

	src.adding = list(  )
	src.other = list(  )
	src.vimpaired = list(  )
	src.darkMask = list(  )

	src.g_dither = new src.h_type( src )
	src.g_dither.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.g_dither.name = "Mask"
	src.g_dither.icon_state = "dither12g"
	src.g_dither.layer = 18
	src.g_dither.mouse_opacity = 0

	src.alien_view = new src.h_type(src)
	src.alien_view.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.alien_view.name = "Alien"
	src.alien_view.icon_state = "alien"
	src.alien_view.layer = 18
	src.alien_view.mouse_opacity = 0

	src.blurry = new src.h_type( src )
	src.blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.blurry.name = "Blurry"
	src.blurry.icon_state = "blurry"
	src.blurry.layer = 17
	src.blurry.mouse_opacity = 0

	src.druggy = new src.h_type( src )
	src.druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.druggy.name = "Druggy"
	src.druggy.icon_state = "druggy"
	src.druggy.layer = 17
	src.druggy.mouse_opacity = 0

	var/obj/screen/using

	using = new src.h_type( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new src.h_type( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

/*
	using = new src.h_type(src) //Right hud bar
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "EAST+1,SOUTH to EAST+1,NORTH"
	using.layer = 19
	src.adding += using

	using = new src.h_type(src) //Lower hud bar
	using.dir = EAST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "WEST,SOUTH-1 to EAST,SOUTH-1"
	using.layer = 19
	src.adding += using

	using = new src.h_type(src) //Corner Button
	using.dir = NORTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "EAST+1,SOUTH-1"
	using.layer = 19
	src.adding += using
*/

	/*
	using = new src.h_type( src )
	using.name = "arrowleft"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "s_arrow"
	using.dir = WEST
	using.screen_loc = ui_iarrowleft
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "arrowright"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "s_arrow"
	using.dir = EAST
	using.screen_loc = ui_iarrowright
	using.layer = 19
	src.adding += using
	*/

	using = new src.h_type( src )
	using.name = "drop"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = 19
	src.adding += using



//equippable shit
	//suit
	using = new src.h_type( src )
	using.name = "o_clothing"
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "equip"
	using.screen_loc = ui_alien_oclothing
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "r_hand"
	using.dir = WEST
	using.icon = 'icons/mob/screen1_alien.dmi'
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
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		using.icon_state = "hand_active"
	using.screen_loc = ui_lhand
	using.layer = 19
	src.l_hand_hud_object = using
	src.adding += using

	//pocket 1
	using = new src.h_type( src )
	using.name = "storage1"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "pocket"
	using.screen_loc = ui_storage1
	using.layer = 19
	src.adding += using

	//pocket 2
	using = new src.h_type( src )
	using.name = "storage2"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "pocket"
	using.screen_loc = ui_storage2
	using.layer = 19
	src.adding += using

	//head
	using = new src.h_type( src )
	using.name = "head"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hair"
	using.screen_loc = ui_alien_head
	using.layer = 19
	src.adding += using
//end of equippable shit

/*
	using = new src.h_type( src )
	using.name = "resist"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_resist
	using.layer = 19
	src.adding += using
*/

	using = new src.h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "1,1 to 5,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using

	using = new src.h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "5,1 to 10,5"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using

	using = new src.h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "6,11 to 10,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using

	using = new src.h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "11,1 to 15,15"
	using.layer = 17
	using.mouse_opacity = 0
	src.vimpaired += using

	mymob.throw_icon = new /obj/screen(null)
	mymob.throw_icon.icon = 'icons/mob/screen1_alien.dmi'
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.oxygen = new /obj/screen( null )
	mymob.oxygen.icon = 'icons/mob/screen1_alien.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_alien_oxygen

	mymob.toxin = new /obj/screen( null )
	mymob.toxin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_alien_toxin

	mymob.fire = new /obj/screen( null )
	mymob.fire.icon = 'icons/mob/screen1_alien.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_alien_fire

	mymob.healths = new /obj/screen( null )
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = new /obj/screen( null )
	mymob.pullin.icon = 'icons/mob/screen1_alien.dmi'
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
	mymob.flash.icon = 'icons/mob/screen1_alien.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	/*
	mymob.hands = new /obj/screen( null )
	mymob.hands.icon = 'icons/mob/screen1_alien.dmi'
	mymob.hands.icon_state = "hand"
	mymob.hands.name = "hand"
	mymob.hands.screen_loc = ui_hand
	mymob.hands.dir = NORTH

	mymob.sleep = new /obj/screen( null )
	mymob.sleep.icon = 'icons/mob/screen1_alien.dmi'
	mymob.sleep.icon_state = "sleep0"
	mymob.sleep.name = "sleep"
	mymob.sleep.screen_loc = ui_sleep

	mymob.rest = new /obj/screen( null )
	mymob.rest.icon = 'icons/mob/screen1_alien.dmi'
	mymob.rest.icon_state = "rest0"
	mymob.rest.name = "rest"
	mymob.rest.screen_loc = ui_rest
	*/


	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.screen = null

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other

