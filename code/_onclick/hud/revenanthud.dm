/datum/hud/revenant
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/revenant/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_living_pull)
	add_screen_object(/atom/movable/screen/healths/revenant, HUD_MOB_HEALTH, HUD_GROUP_INFO)
