/datum/hud
	var/atom/movable/screen/gunhud_screen

/datum/hud/human/initialize_screen_objects()
	. = ..()
	gunhud_screen = add_screen_object(/atom/movable/screen/gunhud_screen, HUD_MOB_GUNHUD, HUD_GROUP_INFO, null, ui_gunhud)

/datum/hud/human/Destroy()
	gunhud_screen = null
	return ..()
