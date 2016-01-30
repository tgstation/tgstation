/datum/hud/proc/larva_hud()
	adding = list()
	other = list()

	var/obj/screen/using

	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_movi
	adding += using
	action_intent = using

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

	mymob.zone_sel = new /obj/screen/zone_sel/alien()
	mymob.zone_sel.icon = 'icons/mob/screen_alien.dmi'
	mymob.zone_sel.update_icon()

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, nightvisionicon, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += adding + other
	mymob.client.screen += mymob.client.void