/datum/hud/dextrous/voidwalker
	ui_style = 'icons/hud/screen_voidwalker.dmi'

/datum/hud/dextrous/voidwalker/initialize_screen_objects()
	. = ..()
	var/atom/movable/screen/floor_change = screen_objects[HUD_MOB_FLOOR_CHANGER]
	floor_change.icon = ui_style
	floor_change.screen_loc = ui_rest

	add_screen_object(/atom/movable/screen/resist, HUD_MOB_RESIST, HUD_GROUP_HOTKEYS, ui_style, ui_voidwalker_left_of_hands)
	add_screen_object(/atom/movable/screen/combattoggle/flashy/voidwalker, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/space_camo, HUD_VOIDWALKER_SPACE_CAMO)
	add_screen_object(/atom/movable/screen/vomit_jump, HUD_VOIDWALKER_VOID_JUMP)

