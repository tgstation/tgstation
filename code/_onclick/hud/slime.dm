/datum/hud/living/slime
	ui_style = 'icons/hud/screen_slimecore.dmi'

/datum/hud/living/slime/initialize_screen_objects()
	. = ..()
	var/mob/living/basic/slime/slime_mob = mymob
	if(!slime_mob.hunger_disabled)
		add_screen_object(/atom/movable/screen/hunger, HUD_MOB_HUNGER, HUD_GROUP_INFO, ui_loc = ui_slime_hunger)
		add_screen_object(/atom/movable/screen/slime_power, HUD_MOB_SLIME_POWER, HUD_GROUP_INFO)
