/datum/hud/lavaland_elite
	ui_style = 'icons/mob/screen_elite.dmi'

/datum/hud/lavaland_elite/New(mob/living/simple_animal/hostile/asteroid/elite/owner)
	..()

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healthdoll = new /obj/screen/healthdoll/lavaland_elite()
	healthdoll.hud = src
	infodisplay += healthdoll
