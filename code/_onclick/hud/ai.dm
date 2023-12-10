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
	. = ..()
	if(.)
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_camera_track()

/atom/movable/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/atom/movable/screen/ai/camera_light/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()

/atom/movable/screen/ai/modpc
	name = "Messenger"
	icon_state = "pda_send"
	var/mob/living/silicon/ai/robot

/atom/movable/screen/ai/modpc/Click()
	. = ..()
	if(.)
		return
	robot.modularInterface?.interact(robot)

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
	var/mob/living/silicon/ai/myai = mymob

// Language menu
	using = new /atom/movable/screen/language_menu(null, src)
	using.screen_loc = ui_ai_language_menu
	static_inventory += using

//AI core
	using = new /atom/movable/screen/ai/aicore(null, src)
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai/camera_list(null, src)
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai/camera_track(null, src)
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai/camera_light(null, src)
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Crew Monitoring
	using = new /atom/movable/screen/ai/crew_monitor(null, src)
	using.screen_loc = ui_ai_crew_monitor
	static_inventory += using

//Crew Manifest
	using = new /atom/movable/screen/ai/crew_manifest(null, src)
	using.screen_loc = ui_ai_crew_manifest
	static_inventory += using

//Alerts
	using = new /atom/movable/screen/ai/alerts(null, src)
	using.screen_loc = ui_ai_alerts
	static_inventory += using

//Announcement
	using = new /atom/movable/screen/ai/announcement(null, src)
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//Shuttle
	using = new /atom/movable/screen/ai/call_shuttle(null, src)
	using.screen_loc = ui_ai_shuttle
	static_inventory += using

//Laws
	using = new /atom/movable/screen/ai/state_laws(null, src)
	using.screen_loc = ui_ai_state_laws
	static_inventory += using

// Modular Interface
	using = new /atom/movable/screen/ai/modpc(null, src)
	using.screen_loc = ui_ai_mod_int
	static_inventory += using
	myai.interfaceButton = using
	var/atom/movable/screen/ai/modpc/tabletbutton = using
	tabletbutton.robot = myai

//Take image
	using = new /atom/movable/screen/ai/image_take(null, src)
	using.screen_loc = ui_ai_take_picture
	static_inventory += using

//View images
	using = new /atom/movable/screen/ai/image_view(null, src)
	using.screen_loc = ui_ai_view_images
	static_inventory += using

//Medical/Security sensors
	using = new /atom/movable/screen/ai/sensors(null, src)
	using.screen_loc = ui_ai_sensor
	static_inventory += using

//Multicamera mode
	using = new /atom/movable/screen/ai/multicam(null, src)
	using.screen_loc = ui_ai_multicam
	static_inventory += using

//Add multicamera camera
	using = new /atom/movable/screen/ai/add_multicam(null, src)
	using.screen_loc = ui_ai_add_multicam
	static_inventory += using
