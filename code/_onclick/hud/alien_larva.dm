/datum/hud/proc/larva_hud()
	adding = list()
	other = list()

	var/obj/screen/using

	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	adding += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == RUN ? "running" : (WALK ? "walking" : "sprinting"))
	using.screen_loc = ui_movi
	adding += using
	move_intent = using

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	nightvisionicon = new /obj/screen/alien/nightvision()
	nightvisionicon.screen_loc = ui_alien_nightvision

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

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

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, nightvisionicon, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other
	mymob.client.screen += mymob.client.void