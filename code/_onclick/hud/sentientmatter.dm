/datum/hud/sentientmatter
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/sentientmatter/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/sentientmatter()
	healths.hud = src
	infodisplay += healths
