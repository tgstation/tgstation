/datum/hud/soulscythe/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/blood_level, HUD_MOB_BLOOD_LEVEL, HUD_GROUP_INFO)
