/datum/hud/living
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	combo_display = new /obj/screen/combo()
	infodisplay += combo_display

	//mob health doll! assumes whatever sprite the mob is
	healthdoll = new /obj/screen/healthdoll/living()
	healthdoll.hud = src
	infodisplay += healthdoll
