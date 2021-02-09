/datum/computer_file/program/ntnetmonitor
	filename = "wirecarp"
	filedesc = "WireCarp"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	requires_ntnet = TRUE
	required_access = ACCESS_NETWORK	//NETWORK CONTROL IS A MORE SECURE PROGRAM.
	available_on_ntnet = TRUE
	tgui_id = "NtosNetMonitor"
	program_icon = "network-wired"

/datum/computer_file/program/ntnetmonitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("resetIDS")
			if(SSnetworks.station_network)
				SSnetworks.station_network.resetIDS()
			return TRUE
		if("toggleIDS")
			if(SSnetworks.station_network)
				SSnetworks.station_network.toggleIDS()
			return TRUE
		if("toggleWireless")
			if(!SSnetworks.station_network)
				return

			// NTNet is disabled. Enabling can be done without user prompt
			if(SSnetworks.station_network.setting_disabled)
				SSnetworks.station_network.setting_disabled = FALSE
				return TRUE

			SSnetworks.station_network.setting_disabled = TRUE
			return TRUE
		if("purgelogs")
			if(SSnetworks.station_network)
				SSnetworks.purge_logs()
			return TRUE
		if("updatemaxlogs")
			var/logcount = params["new_number"]
			if(SSnetworks.station_network)
				SSnetworks.update_max_log_count(logcount)
			return TRUE
		if("toggle_function")
			if(!SSnetworks.station_network)
				return
			SSnetworks.station_network.toggle_function(text2num(params["id"]))
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!SSnetworks.station_network)
		return
	var/list/data = get_header_data()

	data["ntnetstatus"] = SSnetworks.station_network.check_function()
	data["ntnetrelays"] = SSnetworks.relays.len
	data["idsstatus"] = SSnetworks.station_network.intrusion_detection_enabled
	data["idsalarm"] = SSnetworks.station_network.intrusion_detection_alarm

	data["config_softwaredownload"] = SSnetworks.station_network.setting_softwaredownload
	data["config_peertopeer"] = SSnetworks.station_network.setting_peertopeer
	data["config_communication"] = SSnetworks.station_network.setting_communication
	data["config_systemcontrol"] = SSnetworks.station_network.setting_systemcontrol

	data["ntnetlogs"] = list()
	data["minlogs"] = MIN_NTNET_LOGS
	data["maxlogs"] = MAX_NTNET_LOGS

	for(var/i in SSnetworks.logs)
		data["ntnetlogs"] += list(list("entry" = i))
	data["ntnetmaxlogs"] = SSnetworks.setting_maxlogcount

	return data
