/obj/hud/proc/amorph_hud(var/ui_style='screen1_old.dmi')

	src.adding = list(  )
	src.other = list(  )
	src.intents = list(  )
	src.mon_blo = list(  )
	src.m_ints = list(  )
	src.mov_int = list(  )
	src.vimpaired = list(  )
	src.darkMask = list(  )
	src.intent_small_hud_objects = list(  )

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

//intent small hud objects
	using = new src.h_type( src )
	using.name = "help"
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "help" ? "help_small_active" : "help_small")
	using.screen_loc = ui_help_small
	using.layer = 21
	src.adding += using
	help_intent = using

	using = new src.h_type( src )
	using.name = "disarm"
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "disarm" ? "disarm_small_active" : "disarm_small")
	using.screen_loc = ui_disarm_small
	using.layer = 21
	src.adding += using
	disarm_intent = using

	using = new src.h_type( src )
	using.name = "grab"
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "grab" ? "grab_small_active" : "grab_small")
	using.screen_loc = ui_grab_small
	using.layer = 21
	src.adding += using
	grab_intent = using

	using = new src.h_type( src )
	using.name = "harm"
	using.icon = ui_style
	using.icon_state = (mymob.a_intent == "hurt" ? "harm_small_active" : "harm_small")
	using.screen_loc = ui_harm_small
	using.layer = 21
	src.adding += using
	hurt_intent = using

//end intent small hud objects

	using = new src.h_type( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	using = new src.h_type( src )
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_dropbutton
	using.layer = 19
	src.adding += using

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
	using.name = "mask"
	using.dir = NORTH
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_monkey_mask
	using.layer = 19
	src.adding += using

	using = new src.h_type( src )
	using.name = "back"
	using.dir = NORTHEAST
	using.icon = ui_style
	using.icon_state = "equip"
	using.screen_loc = ui_back
	using.layer = 19
	src.adding += using

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

	mymob.throw_icon = new /obj/screen(null)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_throw

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
	mymob.pullin.screen_loc = ui_pull

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = ui_style
	mymob.blind.icon_state = "blackanimate"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1 to 15,15"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.flash = new /obj/screen( null )
	mymob.flash.icon = ui_style
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)

	mymob.client.screen = null

	//, mymob.i_select, mymob.m_select
	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.oxygen, mymob.pressure, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash, mymob.gun_setting_icon) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach, mymob.hands, )
	mymob.client.screen += src.adding + src.other

	//if(istype(mymob,/mob/living/carbon/monkey)) mymob.client.screen += src.mon_blo

	return
