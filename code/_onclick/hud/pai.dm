#define PAI_MISSING_SOFTWARE_MESSAGE "<span class='warning'>You must download the required software to use this.</span>"

/obj/screen/pai
	icon = 'icons/mob/screen_pai.dmi'

/obj/screen/pai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/obj/screen/pai/software
	name = "Software Interface"
	icon_state = "pai"

/obj/screen/pai/software/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.paiInterface()

/obj/screen/pai/shell
	name = "Toggle Holoform"
	icon_state = "pai_holoform"

/obj/screen/pai/shell/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.holoform)
		pAI.fold_in(0)
	else
		pAI.fold_out()

/obj/screen/pai/chassis
	name = "Holochassis Appearance Composite"
	icon_state = "pai_chassis"

/obj/screen/pai/chassis/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.choose_chassis()

/obj/screen/pai/rest
	name = "Rest"
	icon_state = "pai_rest"

/obj/screen/pai/rest/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.lay_down()

/obj/screen/pai/light
	name = "Toggle Integrated Lights"
	icon_state = "light"

/obj/screen/pai/light/Click()
	..()
	var/mob/living/silicon/pai/pAI = usr
	pAI.toggle_integrated_light()

/obj/screen/pai/newscaster
	name = "pAI Newscaster"
	icon_state = "newscaster"
//	color = rgb(128,128,128) need to find a proper way to do this or abandon it

/obj/screen/pai/newscaster/Click()
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("newscaster"))
//		color = rgb(256,256,256)
		pAI.newscaster.ui_interact(usr)
	else to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/host_monitor
	name = "Host Health Scan"
	icon_state = "host_monitor"
//	color = rgb(128,128,128)

/obj/screen/pai/host_monitor/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("host scan"))
		var/mob/living/M = pAI.card.loc
		pAI.hostscan.attack(M, pAI)
//		color = rgb(256,256,256)
	else
		to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"
//	color = rgb(128,128,128)

/obj/screen/pai/crew_manifest/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("crew manifest"))
//		color = rgb(256,256,256)
		pAI.ai_roster()
	else to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

///obj/screen/pai/announcement
//	name = "Make Vox Announcement"
//	icon_state = "announcement"

///obj/screen/pai/announcement/Click()
//	if(..())
//		return
//	var/mob/living/silicon/ai/pAI = usr
//	pAI.announcement()

/obj/screen/pai/state_laws
	name = "State Laws"
	icon_state = "state_laws"

/obj/screen/pai/state_laws/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.checklaws()

/obj/screen/pai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"
//	color = rgb(128,128,128)

/obj/screen/pai/pda_msg_send/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("digital messenger"))
//		color = rgb(256,256,256)
		pAI.cmd_send_pdamesg(usr)
	else
		to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"
//	color = rgb(128,128,128)

/obj/screen/pai/pda_msg_show/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("digital messenger"))
//		color = rgb(256,256,256)
		pAI.cmd_show_message_log(usr)
	else
		to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/image_take
	name = "Take Image"
	icon_state = "take_picture"
//	color = rgb(128,128,128)

/obj/screen/pai/image_take/Click()
	if(..())
		return
	if(issilicon(usr))
		var/mob/living/silicon/pai/pAI = usr
		if(pAI.software.Find("photo"))
//			color = rgb(256,256,256)
			pAI.aicamera.toggle_camera_mode(usr)
		else
			to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/image_view
	name = "View Images"
	icon_state = "view_images"

/obj/screen/pai/image_view/Click()
	if(..())
		return
	if(issilicon(usr))
		var/mob/living/silicon/pai/pAI = usr
		pAI.aicamera.viewpictures(usr)

/obj/screen/pai/sensors
	name = "Sensor Augmentation"
	icon_state = "ai_sensor"
//	color = rgb(128,128,128)

/obj/screen/pai/sensors/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	if(pAI.software.Find("medical HUD"))
		pAI.Topic("medicalhud","toggle")
//		color = rgb(256,256,256)
	if(pAI.software.Find("security HUD"))
		pAI.Topic("securityhud","toggle")
//		color = rgb(256,256,256)
	else
		to_chat(pAI, PAI_MISSING_SOFTWARE_MESSAGE)

/obj/screen/pai/radio
	name = "radio"
	icon = 'icons/mob/screen_cyborg.dmi'
	icon_state = "radio"

/obj/screen/pai/radio/Click()
	if(..())
		return
	var/mob/living/silicon/pai/pAI = usr
	pAI.radio.interact(usr)

/datum/hud/pai/New(mob/owner)
	..()
	var/obj/screen/using

// Software menu
	using = new /obj/screen/pai/software
	using.screen_loc = ui_pai_software
	static_inventory += using

// Holoform
	using = new /obj/screen/pai/shell
	using.screen_loc = ui_pai_shell
	static_inventory += using

// Chassis Select Menu
	using = new /obj/screen/pai/chassis
	using.screen_loc = ui_pai_chassis
	static_inventory += using

// Rest
	using = new /obj/screen/pai/rest
	using.screen_loc = ui_pai_rest
	static_inventory += using

// Integrated Light
	using = new /obj/screen/pai/light
	using.screen_loc = ui_pai_light
	static_inventory += using

// Newscaster
	using = new /obj/screen/pai/newscaster
	using.screen_loc = ui_pai_newscaster
	static_inventory += using

// Language menu
	using = new /obj/screen/language_menu
	using.screen_loc = ui_borg_language_menu
	static_inventory += using

// Host Monitor
	using = new /obj/screen/pai/host_monitor()
	using.screen_loc = ui_pai_host_monitor
	static_inventory += using

// Crew Manifest
	using = new /obj/screen/pai/crew_manifest()
	using.screen_loc = ui_pai_crew_manifest
	static_inventory += using

// Laws
	using = new /obj/screen/pai/state_laws()
	using.screen_loc = ui_pai_state_laws
	static_inventory += using

// PDA message
	using = new /obj/screen/pai/pda_msg_send()
	using.screen_loc = ui_pai_pda_send
	static_inventory += using

// PDA log
	using = new /obj/screen/pai/pda_msg_show()
	using.screen_loc = ui_pai_pda_log
	static_inventory += using

// Take image
	using = new /obj/screen/pai/image_take()
	using.screen_loc = ui_pai_take_picture
	static_inventory += using

// View images
	using = new /obj/screen/pai/image_view()
	using.screen_loc = ui_pai_view_images
	static_inventory += using

// Medical/Security sensors
	using = new /obj/screen/pai/sensors()
	using.screen_loc = ui_pai_sensor
	static_inventory += using

// Radio
	using = new /obj/screen/pai/radio()
	using.screen_loc = ui_borg_radio
	static_inventory += using

	#undef PAI_MISSING_SOFTWARE_MESSAGE