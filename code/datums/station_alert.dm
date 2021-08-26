/datum/station_alert
    /// Holder of the datum
    var/holder
    /// Listens for alarms, provides the alarms list for our ui
    var/datum/alarm_listener/listener
    /// Title of our UI
    var/title

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(loc, list/alarm_types, list/listener_z_level, ui_title)
    holder = loc
    listener = new(alarm_types, listener_z_level)
    title = ui_title

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
	data["alarms"] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		data["alarms"][alarm_type] = list()
		for(var/area_name in alarms[alarm_type])
			data["alarms"][alarm_type] += area_name
	return data
