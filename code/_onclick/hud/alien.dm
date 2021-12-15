/atom/movable/screen/alien
	icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/alien/plasma_display
	name = "plasma stored"
	icon_state = "power_display"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/alert/status_effect/agent_pinpointer/xeno
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "queen_finder"

/mob/living/carbon/human/species/alien/proc/updatePlasmaDisplay()
	if(hud_used) //clientless aliens
		hud_used.alien_plasma_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='magenta'>[round(getPlasma())]</font></div>")

/mob/living/carbon/human/species/alien/larva/updatePlasmaDisplay()
	return


/datum/hud/human/alien
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/human/alien/New(mob/living/carbon/human/species/alien/owner)
	..()

	//remove old ones

	qdel(healths)
	qdel(healthdoll)

	//begin indicators

	healths = new /atom/movable/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	alien_plasma_display = new /atom/movable/screen/alien/plasma_display()
	alien_plasma_display.hud = src
	infodisplay += alien_plasma_display
