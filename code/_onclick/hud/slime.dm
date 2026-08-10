/datum/hud/living/slime
	ui_style = 'icons/hud/screen_slimecore.dmi'

/datum/hud/living/slime/initialize_screen_objects()
	. = ..()
	var/mob/living/basic/slime/slime_mob = mymob
	if(!slime_mob.hunger_disabled)
		add_screen_object(/atom/movable/screen/hunger, HUD_MOB_HUNGER, HUD_GROUP_INFO, ui_loc = "EAST-1:30,CENTER+1:6")
		add_screen_object(/atom/movable/screen/slime_growth, HUD_MOB_SLIME_GROWTH, HUD_GROUP_INFO, ui_loc = "EAST-1:28,CENTER-2:18")
		add_screen_object(/atom/movable/screen/slime_power, HUD_MOB_SLIME_POWER, HUD_GROUP_INFO, ui_loc ="EAST-1:28,CENTER:12")//"WEST:6,CENTER:-2")
