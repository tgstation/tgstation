/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Canary"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for a station's alarm system."
	requires_ntnet = 1
	size = 5
	tgui_id = "NtosStationAlertConsole"
	program_icon = "bell"
	var/has_alert = 0
	///Listens for alarms, manages our listing of alarms
	var/datum/alarm_listener/listener

/datum/computer_file/program/alarm_monitor/New()
	//We want to send an alarm if we're in one of the mining home areas
	//Or if we're on station. Otherwise, die.
	var/list/allowed_areas = GLOB.the_station_areas + typesof(/area/mine)
	listener = new(list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), null, allowed_areas)
	RegisterSignal(listener, list(COMSIG_ALARM_TRIGGERED, COMSIG_ALARM_CLEARED), .proc/update_alarm_display)
	return ..()

/datum/computer_file/program/alarm_monitor/Destroy()
	QDEL_NULL(listener)
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

	data["alarms"] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		data["alarms"][alarm_type] = list()
		for(var/area in alarms[alarm_type])
			data["alarms"][alarm_type] += area

	return data

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	SIGNAL_HANDLER
	has_alert = FALSE
	if(length(listener.alarms))
		has_alert = TRUE

/datum/computer_file/program/alarm_monitor/run_program(mob/user)
	. = ..(user)
	GLOB.alarmdisplay += src

/datum/computer_file/program/alarm_monitor/kill_program(forced = FALSE)
	GLOB.alarmdisplay -= src
	return ..()
