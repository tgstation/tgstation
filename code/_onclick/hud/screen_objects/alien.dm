/atom/movable/screen/alien
	icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"
	screen_loc = ui_alien_storage_r

/atom/movable/screen/alien/leap/Click()
	if(!isalienhunter(usr))
		return
	var/mob/living/carbon/alien/adult/hunter/AH = usr
	AH.toggle_leap()

/atom/movable/screen/alien/plasma_display
	name = "plasma stored"
	icon_state = "power_display"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/alien/alien_queen_finder
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	icon_state = "queen_finder"
	screen_loc = ui_alien_queen_finder
