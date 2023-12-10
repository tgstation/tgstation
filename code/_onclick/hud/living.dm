/datum/hud/living
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	combo_display = new /atom/movable/screen/combo(null, src)
	infodisplay += combo_display

	//mob health doll! assumes whatever sprite the mob is
	healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += healthdoll
