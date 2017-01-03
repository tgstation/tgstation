/datum/hud/larva/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	nightvisionicon = new /obj/screen/alien/nightvision()
	nightvisionicon.screen_loc = ui_alien_nightvision
	infodisplay += nightvisionicon
	alien_queen_finder = new /obj/screen/alien/alien_queen_finder()
	infodisplay += alien_queen_finder
	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	hotkeybuttons += pull_icon

	using = new/obj/screen/wheel/talk
	using.screen_loc = ui_alien_talk_wheel
	wheels += using
	static_inventory += using

	zone_select = new /obj/screen/zone_sel/alien()
	zone_select.update_icon(mymob)
	static_inventory += zone_select

/mob/living/carbon/alien/larva/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/larva(src)
