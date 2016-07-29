<<<<<<< HEAD
/obj/screen/ai
	icon = 'icons/mob/screen_ai.dmi'

/obj/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"

/obj/screen/ai/aicore/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.view_core()

/obj/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/obj/screen/ai/camera_list/Click()
	var/mob/living/silicon/ai/AI = usr
	var/camera = input(AI, "Choose which camera you want to view", "Cameras") as null|anything in AI.get_camera_list()
	AI.ai_camera_list(camera)

/obj/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"

/obj/screen/ai/camera_track/Click()
	var/mob/living/silicon/ai/AI = usr
	var/target_name = input(AI, "Choose who you want to track", "Tracking") as null|anything in AI.trackable_mobs()
	AI.ai_camera_track(target_name)

/obj/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/obj/screen/ai/camera_light/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()

/obj/screen/ai/crew_monitor
	name = "Crew Monitoring Console"
	icon_state = "crew_monitor"

/obj/screen/ai/crew_monitor/Click()
	var/mob/living/silicon/ai/AI = usr
	crewmonitor.show(AI)

/obj/screen/ai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/obj/screen/ai/crew_manifest/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.ai_roster()

/obj/screen/ai/alerts
	name = "Show Alerts"
	icon_state = "alerts"

/obj/screen/ai/alerts/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.ai_alerts()

/obj/screen/ai/announcement
	name = "Make Announcement"
	icon_state = "announcement"

/obj/screen/ai/announcement/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/obj/screen/ai/call_shuttle
	name = "Call Emergency Shuttle"
	icon_state = "call_shuttle"

/obj/screen/ai/call_shuttle/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.ai_call_shuttle()

/obj/screen/ai/state_laws
	name = "State Laws"
	icon_state = "state_laws"

/obj/screen/ai/state_laws/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.checklaws()

/obj/screen/ai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/obj/screen/ai/pda_msg_send/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.cmd_send_pdamesg(usr)

/obj/screen/ai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"

/obj/screen/ai/pda_msg_show/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.cmd_show_message_log(usr)

/obj/screen/ai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/obj/screen/ai/image_take/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aicamera.toggle_camera_mode()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.aicamera.toggle_camera_mode()

/obj/screen/ai/image_view
	name = "View Images"
	icon_state = "view_images"

/obj/screen/ai/image_view/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aicamera.viewpictures()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.aicamera.viewpictures()

/obj/screen/ai/sensors
	name = "Sensor Augmentation"
	icon_state = "ai_sensor"

/obj/screen/ai/sensors/Click()
	var/mob/living/silicon/S = usr
	S.sensor_mode()


/datum/hud/ai/New(mob/owner)
	..()
	var/obj/screen/using

//AI core
	using = new /obj/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /obj/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /obj/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//Camera light
	using = new /obj/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Crew Monitoring
	using = new /obj/screen/ai/crew_monitor()
	using.screen_loc = ui_ai_crew_monitor
	static_inventory += using

//Crew Manifest
	using = new /obj/screen/ai/crew_manifest()
	using.screen_loc = ui_ai_crew_manifest
	static_inventory += using

//Alerts
	using = new /obj/screen/ai/alerts()
	using.screen_loc = ui_ai_alerts
	static_inventory += using

//Announcement
	using = new /obj/screen/ai/announcement()
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//Shuttle
	using = new /obj/screen/ai/call_shuttle()
	using.screen_loc = ui_ai_shuttle
	static_inventory += using

//Laws
	using = new /obj/screen/ai/state_laws()
	using.screen_loc = ui_ai_state_laws
	static_inventory += using

//PDA message
	using = new /obj/screen/ai/pda_msg_send()
	using.screen_loc = ui_ai_pda_send
	static_inventory += using

//PDA log
	using = new /obj/screen/ai/pda_msg_show()
	using.screen_loc = ui_ai_pda_log
	static_inventory += using

//Take image
	using = new /obj/screen/ai/image_take()
	using.screen_loc = ui_ai_take_picture
	static_inventory += using

//View images
	using = new /obj/screen/ai/image_view()
	using.screen_loc = ui_ai_view_images
	static_inventory += using


//Medical/Security sensors
	using = new /obj/screen/ai/sensors()
	using.screen_loc = ui_ai_sensor
	static_inventory += using


/mob/living/silicon/ai/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ai(src)
=======
// Ported from /tg/

/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/obj/screen/using

//AI core
	using = getFromPool(/obj/screen)
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = 20
	adding += using

//Camera list
	using = getFromPool(/obj/screen)
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = 20
	adding += using

//Track
	using = getFromPool(/obj/screen)
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = 20
	adding += using

//Camera light
	using = getFromPool(/obj/screen)
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = 20
	adding += using

//Crew Manifest
	using = getFromPool(/obj/screen)
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = 20
	adding += using

//Alerts
	using = getFromPool(/obj/screen)
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = 20
	adding += using

//Announcement
	using = getFromPool(/obj/screen)
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = 20
	adding += using

//Shuttle
	using = getFromPool(/obj/screen)
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = 20
	adding += using

//Laws
	using = getFromPool(/obj/screen)
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = 20
	adding += using

//PDA message
	using = getFromPool(/obj/screen)
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = 20
	adding += using

//PDA log
	using = getFromPool(/obj/screen)
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = 20
	adding += using

//Take image
	using = getFromPool(/obj/screen)
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = 20
	adding += using

//View images
	using = getFromPool(/obj/screen)
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = 20
	adding += using

//Radio Configuration
	using = getFromPool(/obj/screen)
	using.name = "Configure Radio"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "change_radio"
	using.screen_loc = ui_ai_config_radio
	using.layer = 20
	adding += using

	mymob.client.screen += adding

	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
