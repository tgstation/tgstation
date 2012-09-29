

/datum/hud/proc/larva_hud()

	src.adding = list(  )
	src.other = list(  )

	var/obj/screen/using

	using = new /obj/screen( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	action_intent = using

	using = new /obj/screen( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

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

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.screen = null

	mymob.client.screen += list( mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other



