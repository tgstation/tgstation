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

/datum/computer_file/program/alarm_monitor/New()
	//We want to send an alarm if we're in one of the mining home areas
	//Or if we're on station. Otherwise, die.
	var/list/allowed_areas = GLOB.the_station_areas + typesof(/area/mine)
	alert_control = new(computer, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), listener_areas = allowed_areas)
	RegisterSignal(alert_control.listener, list(COMSIG_ALARM_TRIGGERED, COMSIG_ALARM_CLEARED), .proc/update_alarm_display)
	return ..()

/datum/computer_file/program/alarm_monitor/Destroy()
	QDEL_NULL(alert_control)
	return ..()

/datum/computer_file/program/alarm_monitor/process_tick()
	..()

	if(has_alert)
		program_icon_state = "alert-red"
		ui_header = "alarm_red.gif"
		update_computer_icon()
	else
		if(!has_alert)
			program_icon_state = "alert-green"
			ui_header = "alarm_green.gif"
			update_computer_icon()
	return 1

/datum/computer_file/program/alarm_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	data += alert_control.ui_data(user)
	return data

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	SIGNAL_HANDLER
	has_alert = FALSE
	if(length(alert_control.listener.alarms))
		has_alert = TRUE

/datum/computer_file/program/alarm_monitor/run_program(mob/user)
	. = ..(user)
	GLOB.alarmdisplay += src

/datum/computer_file/program/alarm_monitor/kill_program(forced = FALSE)
	GLOB.alarmdisplay -= src
	return ..()
