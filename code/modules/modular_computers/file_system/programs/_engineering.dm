// These programs are associated with engineering.

/datum/computer_file/program/power_monitor
	filename = "powermonitor"
	filedesc = "Power Monitoring"
	nanomodule_path = /datum/nano_module/power_monitor/
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to sensors around the station to provide information about electrical systems"
	ui_header = "power_norm.gif"
	required_access = access_engine
	requires_ntnet = 1
	network_destination = "power monitoring system"
	size = 9
	var/has_alert = 0

/datum/computer_file/program/power_monitor/process_tick()
	..()
	var/datum/nano_module/power_monitor/NMA = NM
	if(istype(NMA) && NMA.has_alarm())
		if(!has_alert)
			program_icon_state = "power_monitor_warn"
			ui_header = "power_warn.gif"
			update_computer_icon()
			has_alert = 1
	else
		if(has_alert)
			program_icon_state = "power_monitor"
			ui_header = "power_norm.gif"
			update_computer_icon()
			has_alert = 0

/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm Monitoring"
	nanomodule_path = /datum/nano_module/alarm_monitor/engineering
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for station's alarm system."
	requires_ntnet = 1
	network_destination = "alarm monitoring network"
	size = 5
	var/has_alert = 0

/datum/computer_file/program/alarm_monitor/process_tick()
	..()
	var/datum/nano_module/alarm_monitor/NMA = NM
	if(istype(NMA) && NMA.has_major_alarms())
		if(!has_alert)
			program_icon_state = "alert-red"
			ui_header = "alarm_red.gif"
			update_computer_icon()
			has_alert = 1
	else
		if(has_alert)
			program_icon_state = "alert-green"
			ui_header = "alarm_green.gif"
			update_computer_icon()
			has_alert = 0
	return 1

/datum/computer_file/program/atmos_control
	filename = "atmoscontrol"
	filedesc = "Atmosphere Control"
	nanomodule_path = /datum/nano_module/atmos_control
	program_icon_state = "atmos_control"
	extended_desc = "This program allows remote control of air alarms around the station. This program can not be run on tablet computers."
	required_access = access_atmospherics
	requires_ntnet = 1
	network_destination = "atmospheric control system"
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	usage_flags = PROGRAM_LAPTOP | PROGRAM_CONSOLE
	size = 17

/datum/computer_file/program/rcon_console
	filename = "rconconsole"
	filedesc = "RCON Remote Control"
	nanomodule_path = /datum/nano_module/rcon
	program_icon_state = "generic"
	extended_desc = "This program allows remote control of power distribution systems around the station. This program can not be run on tablet computers."
	required_access = access_engine
	requires_ntnet = 1
	network_destination = "RCON remote control system"
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	usage_flags = PROGRAM_LAPTOP | PROGRAM_CONSOLE
	size = 19
