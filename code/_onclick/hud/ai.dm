/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/obj/screen/using

//AI core
	using = new /obj/screen()
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = 20
	adding += using

//Camera list
	using = new /obj/screen()
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = 20
	adding += using

//Track
	using = new /obj/screen()
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = 20
	adding += using

//Camera light
	using = new /obj/screen()
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = 20
	adding += using

//Crew Monitorting
	using = new /obj/screen()
	using.name = "Crew Monitorting"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "crew_monitor"
	using.screen_loc = ui_ai_crew_monitor
	using.layer = 20
	adding += using

//Crew Manifest
	using = new /obj/screen()
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = 20
	adding += using

//Alerts
	using = new /obj/screen()
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = 20
	adding += using

//Announcement
	using = new /obj/screen()
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = 20
	adding += using

//Shuttle
	using = new /obj/screen()
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = 20
	adding += using

//Laws
	using = new /obj/screen()
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = 20
	adding += using

//PDA message
	using = new /obj/screen()
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = 20
	adding += using

//PDA log
	using = new /obj/screen()
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = 20
	adding += using

//Take image
	using = new /obj/screen()
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = 20
	adding += using

//View images
	using = new /obj/screen()
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = 20
	adding += using


//Medical/Security sensors
	using = new /obj/screen()
	using.name = "Sensor Augmentation"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	using.layer = 20
	adding += using

	mymob.client.screen += adding + other
	return