/datum/hud/living
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/living/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_living_pull)
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS)
	add_screen_object(/atom/movable/screen/healthdoll/living, HUD_MOB_HEALTH, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/stamina, HUD_MOB_STAMINA, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER)
