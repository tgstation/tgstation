/atom/movable/screen/alien
	icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/atom/movable/screen/alien/leap/Click()
	if(isalienhunter(usr))
		var/mob/living/carbon/human/species/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/atom/movable/screen/alien/plasma_display
	name = "plasma stored"
	icon_state = "power_display"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/alert/status_effect/agent_pinpointer/xeno
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "queen_finder"



/datum/hud/human/alien
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/human/alien/New(mob/living/carbon/human/species/alien/humanoid/owner)
	..()

	if(isalienhunter(mymob))
		var/mob/living/carbon/human/species/alien/humanoid/hunter/H = mymob
		H.leap_icon = new /atom/movable/screen/alien/leap()
		H.leap_icon.screen_loc = ui_alien_storage_r
		static_inventory += H.leap_icon

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
