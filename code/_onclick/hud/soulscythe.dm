/datum/hud/soulscythe
	needs_health_indicator = FALSE //we use blood level instead.

/datum/hud/soulscythe/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/blood_level, HUD_MOB_BLOOD_LEVEL, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style, ui_loc = ui_zonesel)
