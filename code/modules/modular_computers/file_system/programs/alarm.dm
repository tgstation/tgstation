/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Canary"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for a station's alarm system."
	requires_ntnet = 1
	size = 4
	tgui_id = "NtosStationAlertConsole"
	program_icon = "bell"
	/// If there is any station alert
	var/has_alert = FALSE
	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control

/datum/computer_file/program/alarm_monitor/on_install()
	. = ..()
	//We want to send an alarm if we're in one of the mining home areas
	//Or if we're on station. Otherwise, die.
	var/list/allowed_areas = GLOB.the_station_areas + typesof(/area/mine)
	alert_control = new(computer, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), listener_areas = allowed_areas)
	RegisterSignals(alert_control.listener, list(COMSIG_ALARM_LISTENER_TRIGGERED, COMSIG_ALARM_LISTENER_CLEARED), PROC_REF(update_alarm_display))

/datum/computer_file/program/alarm_monitor/Destroy()
	QDEL_NULL(alert_control)
	return ..()

/datum/computer_file/program/alarm_monitor/ui_data(mob/user)
	var/list/data = list()
	data += alert_control.ui_data(user)
	return data

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	SIGNAL_HANDLER
	// has_alert is true if there are any active alarms in our listener.
	has_alert = (length(alert_control.listener.alarms) > 0)

	if(!has_alert)
		program_icon_state = "alert-green"
		ui_header = "alarm_green.gif"
	else
		// If we don't know the status, assume the worst.
		// Technically we should never have anything other than a truthy or falsy value
		// but this will allow for unknown values to fall through to be an actual alert.
		program_icon_state = "alert-red"
		ui_header = "alarm_red.gif"
	update_computer_icon() // Always update the icon after we check our conditional because we might've changed it

/datum/computer_file/program/alarm_monitor/on_start(mob/user)
	. = ..(user)
	GLOB.alarmdisplay += src

/datum/computer_file/program/alarm_monitor/kill_program()
	GLOB.alarmdisplay -= src
	return ..()
