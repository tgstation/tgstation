/datum/hud/revenant
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/revenant/New(mob/owner)
	..()

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/revenant()
	healths.hud = src
	infodisplay += healths
