/atom/movable/screen/ai
	icon = 'icons/hud/screen_ai.dmi'

/atom/movable/screen/ai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/atom/movable/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"

/atom/movable/screen/ai/aicore/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.view_core()

/atom/movable/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/atom/movable/screen/ai/camera_list/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.show_camera_list()

/atom/movable/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"

/atom/movable/screen/ai/camera_track/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	var/target_name = tgui_input_list(AI, "Select a target", "Tracking", AI.trackable_mobs())
	if(isnull(target_name))
		return
	AI.ai_camera_track(target_name)

/atom/movable/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/atom/movable/screen/ai/camera_light/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()

/atom/movable/screen/ai/crew_monitor
	name = "Crew Monitoring Console"
	icon_state = "crew_monitor"

/atom/movable/screen/ai/crew_monitor/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	GLOB.crewmonitor.show(AI,AI)

/atom/movable/screen/ai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/atom/movable/screen/ai/crew_manifest/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_roster()

/atom/movable/screen/ai/alerts
	name = "Show Alerts"
	icon_state = "alerts"

/atom/movable/screen/ai/alerts/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.alert_control.ui_interact(AI)

/atom/movable/screen/ai/announcement
	name = "Make Vox Announcement"
	icon_state = "announcement"

/atom/movable/screen/ai/announcement/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/atom/movable/screen/ai/call_shuttle
	name = "Call Emergency Shuttle"
	icon_state = "call_shuttle"

/atom/movable/screen/ai/call_shuttle/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_call_shuttle()

/atom/movable/screen/ai/state_laws
	name = "State Laws"
	icon_state = "state_laws"

/atom/movable/screen/ai/state_laws/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.checklaws()

/atom/movable/screen/ai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/atom/movable/screen/ai/pda_msg_send/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.cmd_send_pdamesg(usr)

/atom/movable/screen/ai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"

/atom/movable/screen/ai/pda_msg_show/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.cmd_show_message_log(usr)

/atom/movable/screen/ai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/atom/movable/screen/ai/image_take/Click()
	if(..())
		return
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aicamera.toggle_camera_mode(usr)
	else if(iscyborg(usr))
		var/mob/living/silicon/robot/R = usr
		R.aicamera.toggle_camera_mode(usr)

/atom/movable/screen/ai/image_view
	name = "View Images"
	icon_state = "view_images"

/atom/movable/screen/ai/image_view/Click()
	if(..())
		return
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aicamera.viewpictures(usr)

/atom/movable/screen/ai/sensors
	name = "Sensor Augmentation"
	icon_state = "ai_sensor"

/atom/movable/screen/ai/sensors/Click()
	if(..())
		return
	var/mob/living/silicon/S = usr
	S.toggle_sensors()

/atom/movable/screen/ai/multicam
	name = "Multicamera Mode"
	icon_state = "multicam"

/atom/movable/screen/ai/multicam/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_multicam()

/atom/movable/screen/ai/add_multicam
	name = "New Camera"
	icon_state = "new_cam"

/atom/movable/screen/ai/add_multicam/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.drop_new_multicam()


/datum/hud/ai
	ui_style = 'icons/hud/screen_ai.dmi'

/datum/hud/ai/New(mob/owner)
	..()
	var/atom/movable/screen/using

// Language menu
	using = new /atom/movable/screen/language_menu
	using.screen_loc = ui_ai_language_menu
	using.hud = src
	static_inventory += using

//AI core
	using = new /atom/movable/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	using.hud = src
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	using.hud = src
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	using.hud = src
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	using.hud = src
	static_inventory += using

//Crew Monitoring
	using = new /atom/movable/screen/ai/crew_monitor()
	using.screen_loc = ui_ai_crew_monitor
	using.hud = src
	static_inventory += using

//Crew Manifest
	using = new /atom/movable/screen/ai/crew_manifest()
	using.screen_loc = ui_ai_crew_manifest
	using.hud = src
	static_inventory += using

//Alerts
	using = new /atom/movable/screen/ai/alerts()
	using.screen_loc = ui_ai_alerts
	using.hud = src
	static_inventory += using

//Announcement
	using = new /atom/movable/screen/ai/announcement()
	using.screen_loc = ui_ai_announcement
	using.hud = src
	static_inventory += using

//Shuttle
	using = new /atom/movable/screen/ai/call_shuttle()
	using.screen_loc = ui_ai_shuttle
	using.hud = src
	static_inventory += using

//Laws
	using = new /atom/movable/screen/ai/state_laws()
	using.screen_loc = ui_ai_state_laws
	using.hud = src
	static_inventory += using

//PDA message
	using = new /atom/movable/screen/ai/pda_msg_send()
	using.screen_loc = ui_ai_pda_send
	using.hud = src
	static_inventory += using

//PDA log
	using = new /atom/movable/screen/ai/pda_msg_show()
	using.screen_loc = ui_ai_pda_log
	using.hud = src
	static_inventory += using

//Take image
	using = new /atom/movable/screen/ai/image_take()
	using.screen_loc = ui_ai_take_picture
	using.hud = src
	static_inventory += using

//View images
	using = new /atom/movable/screen/ai/image_view()
	using.screen_loc = ui_ai_view_images
	using.hud = src
	static_inventory += using

//Medical/Security sensors
	using = new /atom/movable/screen/ai/sensors()
	using.screen_loc = ui_ai_sensor
	using.hud = src
	static_inventory += using

//Multicamera mode
	using = new /atom/movable/screen/ai/multicam()
	using.screen_loc = ui_ai_multicam
	using.hud = src
	static_inventory += using

//Add multicamera camera
	using = new /atom/movable/screen/ai/add_multicam()
	using.screen_loc = ui_ai_add_multicam
	using.hud = src
	static_inventory += using
