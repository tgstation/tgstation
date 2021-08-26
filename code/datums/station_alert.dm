/datum/station_alert
    /// Holder of the datum
    var/holder
    /// List of alarm types we are listening to
    var/list/alarm_types
    /// Listens for alarms, provides the alarms list for our ui
    var/datum/alarm_listener/listener
    /// Title of our UI
    var/title

/datum/station_alert/ui_host(mob/user)
	return holder

/datum/station_alert/New(holder, list/alarm_types, list/listener_z_level, title)
    src.holder = holder
    src.alarm_types = alarm_types
    src.title = title
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
	data["alarms"] = list()
	for(var/required_alarm in alarm_types)
		data["alarms"][required_alarm] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		var/list/category = list(
			"name" = alarm_type,
			"alerts" = list(),
		)
		var/list/alerts = alarms[alarm_type]
		for(var/alert in alerts)
			var/list/alarm = alerts[alert]
			category["alerts"] += list(list(
				"name" = alarm[1],
				"cameras" = length(alarm[2]),
			))
		data["alarms"][alarm_type] += list(category)
	return data
