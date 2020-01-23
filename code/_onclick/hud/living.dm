/datum/hud/living
	ui_style = 'icons/mob/screen_gen.dmi'

/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon


	//explanation: since living mobs have no limbs, they only need one of these to show health nicely.
	//while health doll is cooler, it does not work on huge mobs and so they use the basic version.
	if(owner.mob_biotypes & MOB_EPIC)
		healths = new /obj/screen/healths/living()
		healths.hud = src
		infodisplay += healths
	else
		healthdoll = new /obj/screen/healthdoll/living()
		healthdoll.hud = src
		infodisplay += healthdoll
