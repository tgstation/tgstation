/datum/hud/larva
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/larva/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_alien_floor_change)
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/rest, HUD_MOB_REST, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/sleep, HUD_MOB_SLEEP, HUD_GROUP_HOTKEYS, ui_style, ui_drop_throw)
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, ui_loc = ui_alien_language_menu)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, ui_loc = ui_alien_navigate_menu)
	add_screen_object(/atom/movable/screen/zone_sel/alien, HUD_MOB_ZONE_SELECTOR)
	add_screen_object(/atom/movable/screen/healths/alien, HUD_MOB_HEALTH, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/alien/alien_queen_finder, HUD_ALIEN_QUEEN_FINDER, HUD_GROUP_INFO)
