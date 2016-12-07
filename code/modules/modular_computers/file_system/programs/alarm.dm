


/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm Monitoring"
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for station's alarm system."
	requires_ntnet = 1
	network_destination = "alarm monitoring network"
	size = 5
	var/has_alert = 0
	var/alarms = list("Fire" = list(), "Atmosphere" = list(), "Power" = list())
	var/alarm_z = list(ZLEVEL_STATION,ZLEVEL_LAVALAND)

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



/datum/computer_file/program/alarm_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "station_alert_prog", "Alarm Monitoring", 300, 500, master_ui, state)
		ui.open()

/datum/computer_file/program/alarm_monitor/ui_data(mob/user)
	var/list/data = get_header_data()

	data["alarms"] = list()
	for(var/class in alarms)
		data["alarms"][class] = list()
		for(var/area in alarms[class])
			data["alarms"][class] += area

	return data

/datum/computer_file/program/alarm_monitor/proc/triggerAlarm(class, area/A, O, obj/source)

	if(!(source.z in alarm_z))
		return

	var/list/L = alarms[class]
	for(var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(source in sources))
				sources += source
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if(O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if(O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C ? C : O), list(source))

	update_alarm_display()

	return 1


/datum/computer_file/program/alarm_monitor/proc/cancelAlarm(class, area/A, obj/origin)


	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I

	update_alarm_display()
	return !cleared

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	has_alert = FALSE
	for(var/cat in alarms)
		var/list/L = alarms[cat]
		if(L.len)
			has_alert = TRUE

/datum/computer_file/program/alarm_monitor/run_program(mob/user)
	. = ..(user)
	alarmdisplay += src

/datum/computer_file/program/alarm_monitor/kill_program(forced = FALSE)
	alarmdisplay -= src
	..()