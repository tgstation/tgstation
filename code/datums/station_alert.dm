/datum/station_alert
    /// Holder of the datum
    var/holder
    /// List of alarm types we are listening to
    var/list/alarm_types
    /// Listens for alarms, provides the alarms list for our ui
    var/datum/alarm_listener/listener
    /// Title of our UI
    var/title
	/// If UI will also show cameras connected to each alert area
    var/camera_view = FALSE

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(holder, list/alarm_types, list/listener_z_level, title, camera_view)
    src.holder = holder
    src.alarm_types = alarm_types
    src.title = title
    src.camera_view = camera_view
    listener = new(alarm_types, listener_z_level)

/datum/station_alert/Destroy()
    QDEL_NULL(listener)
    return ..()

/datum/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", title)
		ui.open()

/datum/station_alert/ui_data(mob/user)
	var/list/data = list()
	data["cameraView"] = camera_view
	data["alarms"] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		var/list/category = list(
			"name" = alarm_type,
			"alerts" = list(),
		)
		var/list/alerts = alarms[alarm_type]
		for(var/alert in alerts)
			var/list/alarm = alerts[alert]
			var/area/area_name = alarm[1]
			category["alerts"] += list(list(
				"name" = area_name,
				"cameras" = camera_view ? length(alarm[2]) : null,
                "sources" = camera_view ? length(alarm[3]) : null,
				"ref" = camera_view ? REF(alert) : null,
			))
		data["alarms"] += list(category)
	return data

/datum/station_alert/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/silicon/ai/ai = usr
	if(!istype(ai))
		return

	var/list/alarms = listener.alarms
	var/list/alerts = list()
	for(var/alarm_type in alarms)
		alerts += alarms[alarm_type]

	var/list/chosen_alert = locate(params["alert"]) in alerts
	var/list/cameras = chosen_alert[2]

	switch(action)
		if("select_camera")
			var/selected_camera = tgui_input_list(usr, "Choose to which camera you want to jump.", "Camera Selection", cameras)
			ai.switchCamera(locate(selected_camera) in GLOB.cameranet.cameras)
			return TRUE
