///Hud type with targeting dol and a nutrition bar
/datum/hud/ooze/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/zone_sel, HUD_MOB_ZONE_SELECTOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/ooze_nutrition_display, HUD_OOZE_NUTRITION_DISPLAY)

/atom/movable/screen/ooze_nutrition_display
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "power_display"
	name = "nutrition"
	screen_loc = ui_alienplasmadisplay
