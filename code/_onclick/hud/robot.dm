/datum/hud/robot
	ui_style = 'icons/hud/screen_cyborg.dmi'

/datum/hud/robot/initialize_screen_objects()
	. = ..()
	// i, Robit
	var/mob/living/silicon/robot/robit = mymob
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, HUD_GROUP_STATIC, ui_style, ui_borg_language_menu)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, HUD_GROUP_STATIC, ui_style, ui_borg_navigate_menu)
	add_screen_object(/atom/movable/screen/memories, HUD_MOB_MEMORIES, HUD_GROUP_STATIC, ui_style, ui_borg_memories_menu)
	add_screen_object(/atom/movable/screen/robot/radio, HUD_CYBORG_RADIO)

	// Cyborg modules are their "hands", and use hand keys for ease of handling as they behave functionally the same
	// Generic code can just typecheck for /atom/movable/screen/inventory/hud if it needs explicitly hands
	for (var/i in BORG_CHOOSE_MODULE_ONE to BORG_CHOOSE_MODULE_THREE)
		var/atom/movable/screen/robot/module_slot/module = add_screen_object(/atom/movable/screen/robot/module_slot, HUD_KEY_HAND_SLOT(i))
		module.set_slot(i)

	add_screen_object(/atom/movable/screen/robot/lamp, HUD_CYBORG_LAMP)
	add_screen_object(/atom/movable/screen/ai/image_take, HUD_SILICON_TAKE_IMAGE, ui_loc = ui_borg_camera)

	var/atom/movable/screen/robot/modpc/tablet = add_screen_object(/atom/movable/screen/robot/modpc, HUD_SILICON_TABLET, HUD_GROUP_STATIC)
	if(robit.modularInterface)
		// Just trust me
		robit.modularInterface.vis_flags |= VIS_INHERIT_PLANE
		tablet.vis_contents += robit.modularInterface

	add_screen_object(/atom/movable/screen/robot/alerts, HUD_SILICON_ALERTS)
	add_screen_object(/atom/movable/screen/combattoggle/robot, HUD_MOB_INTENTS, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_borg_floor_changer)
	add_screen_object(/atom/movable/screen/zone_sel/robot, HUD_MOB_ZONE_SELECTOR)
	var/atom/movable/screen/robot/module/module = add_screen_object(/atom/movable/screen/robot/module, HUD_CYBORG_HANDS, ui_loc = ui_borg_module)
	module.icon_state = robit.model ? robit.model.model_select_icon : "nomod"

	add_screen_object(/atom/movable/screen/healths/robot, HUD_MOB_HEALTH, HUD_GROUP_INFO)

	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_HOTKEYS, ui_style, ui_borg_pull)
