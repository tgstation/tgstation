#define PAI_MISSING_SOFTWARE_MESSAGE span_warning("You must download the required software to use this.")

/atom/movable/screen/pai
	icon = 'icons/hud/screen_pai.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/required_software

/atom/movable/screen/pai/Click()
	if(isobserver(usr) || usr.incapacitated)
		return FALSE
	var/mob/living/silicon/pai/user = usr
	if(required_software && !user.installed_software.Find(required_software))
		to_chat(user, PAI_MISSING_SOFTWARE_MESSAGE)
		return FALSE
	return TRUE

/atom/movable/screen/pai/software
	name = "Software Interface"
	icon_state = "pai"
	screen_loc = ui_pai_software

/atom/movable/screen/pai/software/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.ui_interact(pAI)

/atom/movable/screen/pai/shell
	name = "Toggle Holoform"
	icon_state = "pai_holoform"
	screen_loc = ui_pai_shell

/atom/movable/screen/pai/shell/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.holoform)
		pAI.fold_in(0)
	else
		pAI.fold_out()

/atom/movable/screen/pai/chassis
	name = "Holochassis Appearance Composite"
	icon_state = "pai_chassis"
	screen_loc = ui_pai_chassis

/atom/movable/screen/pai/chassis/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.choose_chassis()

/atom/movable/screen/pai/rest
	name = "Rest"
	icon_state = "pai_rest"
	screen_loc = ui_pai_rest

/atom/movable/screen/pai/rest/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.toggle_resting()

/atom/movable/screen/pai/light
	name = "Toggle Integrated Lights"
	icon_state = "light"
	screen_loc = ui_pai_light

/atom/movable/screen/pai/light/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.toggle_integrated_light()

/atom/movable/screen/pai/newscaster
	name = "pAI Newscaster"
	icon_state = "newscaster"
	screen_loc = ui_pai_newscaster
	required_software = "Newscaster"

/atom/movable/screen/pai/newscaster/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.newscaster.ui_interact(usr)

/atom/movable/screen/pai/host_monitor
	name = "Host Health Scan"
	icon_state = "host_monitor"
	screen_loc = ui_pai_host_monitor
	required_software = "Host Scan"

/atom/movable/screen/pai/host_monitor/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/pai/pAI = usr
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		pAI.host_scan(PAI_SCAN_TARGET)
		return TRUE
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		pAI.host_scan(PAI_SCAN_MASTER)
		return TRUE

/atom/movable/screen/pai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"
	screen_loc = ui_pai_crew_manifest
	required_software = "Crew Manifest"

/atom/movable/screen/pai/crew_manifest/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.ai_roster()

/atom/movable/screen/pai/state_laws
	name = "State Laws"
	icon_state = "state_laws"
	screen_loc = ui_pai_state_laws

/atom/movable/screen/pai/state_laws/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.checklaws()

/atom/movable/screen/pai/modpc
	name = "Messenger"
	icon_state = "pda_send"
	screen_loc = ui_pai_mod_int
	required_software = "Digital Messenger"

/atom/movable/screen/pai/modpc/Click()
	. = ..()
	if(!.) // this works for some reason.
		return
	var/mob/living/silicon/pai/pAI = usr
	if (istype(pAI))
		pAI.modularInterface?.interact(pAI)

/atom/movable/screen/pai/internal_gps
	name = "Internal GPS"
	icon_state = "internal_gps"
	screen_loc = ui_pai_internal_gps
	required_software = "Internal GPS"

/atom/movable/screen/pai/internal_gps/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/pai/pAI = usr
	if(!pAI.internal_gps)
		pAI.internal_gps = new(pAI)
	pAI.internal_gps.attack_self(pAI)

/atom/movable/screen/pai/image_take
	name = "Take Image"
	icon_state = "take_picture"
	screen_loc = ui_pai_take_picture
	required_software = "Photography Module"

/atom/movable/screen/pai/image_take/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.aicamera.toggle_camera_mode(usr)

/atom/movable/screen/pai/image_view
	name = "View Images"
	icon_state = "view_images"
	screen_loc = ui_pai_view_images
	required_software = "Photography Module"

/atom/movable/screen/pai/image_view/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.aicamera.viewpictures(usr)

/atom/movable/screen/pai/radio
	name = "radio"
	icon = 'icons/hud/screen_cyborg.dmi'
	icon_state = "radio"
	screen_loc = ui_pai_radio

/atom/movable/screen/pai/radio/Click()
	if(!..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.radio.interact(usr)

#undef PAI_MISSING_SOFTWARE_MESSAGE
