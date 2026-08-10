/datum/hud/living/slime
	ui_style = 'icons/hud/screen_slimecore.dmi'

/datum/hud/living/slime/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/hunger, HUD_MOB_HUNGER, HUD_GROUP_INFO)
