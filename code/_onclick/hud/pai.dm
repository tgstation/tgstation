
/datum/hud/pai/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, ui_loc = ui_pai_language_menu)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, ui_loc = ui_pai_navigate_menu)

	add_screen_object(/atom/movable/screen/pai/software, HUD_PAI_SOFTWARE)
	add_screen_object(/atom/movable/screen/pai/shell, HUD_PAI_SHELL)
	add_screen_object(/atom/movable/screen/pai/chassis, HUD_PAI_CHASSIS)
	add_screen_object(/atom/movable/screen/pai/rest, HUD_MOB_REST)
	add_screen_object(/atom/movable/screen/pai/light, HUD_CYBORG_LAMP)
	add_screen_object(/atom/movable/screen/pai/newscaster, HUD_PAI_NEWSCASTER)
	add_screen_object(/atom/movable/screen/pai/host_monitor, HUD_PAI_HOST_MONITOR)
	add_screen_object(/atom/movable/screen/pai/crew_manifest, HUD_AI_CREW_MANIFEST)
	add_screen_object(/atom/movable/screen/pai/state_laws, HUD_AI_STATE_LAWS)
	add_screen_object(/atom/movable/screen/pai/internal_gps, HUD_PAI_GPS)
	add_screen_object(/atom/movable/screen/pai/image_take, HUD_AI_TAKE_IMAGE)
	add_screen_object(/atom/movable/screen/pai/image_view, HUD_AI_IMAGE_VIEW)
	add_screen_object(/atom/movable/screen/pai/radio, HUD_CYBORG_RADIO)
	add_screen_object(/atom/movable/screen/pai/modpc, HUD_SILICON_TABLET)

	update_software_buttons()

/datum/hud/pai/proc/update_software_buttons()
	var/mob/living/silicon/pai/owner = mymob
	for(var/atom/movable/screen/pai/button in screen_objects)
		if(button.required_software)
			button.color = owner.installed_software.Find(button.required_software) ? null : COLOR_GRAY
