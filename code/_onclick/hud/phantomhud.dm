/datum/hud/phantom
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/phantom/New(mob/owner)
	..()

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/phantom(null, src)
	infodisplay += healths
