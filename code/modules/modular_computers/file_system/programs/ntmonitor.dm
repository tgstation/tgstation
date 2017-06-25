/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"
	filedesc = "NTNet Diagnostics and Monitoring"
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	requires_ntnet = 1
	required_access = GLOB.access_network	//Network control is a more secure program.
	available_on_ntnet = 1
	tgui_id = "ntos_net_monitor"

/datum/computer_file/program/ntnetmonitor/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("resetIDS")
			. = 1
			if(GLOB.ntnet_global)
				GLOB.ntnet_global.resetIDS()
			return 1
		if("toggleIDS")
			. = 1
			if(GLOB.ntnet_global)
				GLOB.ntnet_global.toggleIDS()
			return 1
		if("toggleWireless")
			. = 1
			if(!GLOB.ntnet_global)
				return 1

			// NTNet is disabled. Enabling can be done without user prompt
			if(GLOB.ntnet_global.setting_disabled)
				GLOB.ntnet_global.setting_disabled = 0
				return 1

			// NTNet is enabled and user is about to shut it down. Let's ask them if they really want to do it, as wirelessly connected computers won't connect without NTNet being enabled (which may prevent people from turning it back on)
			var/mob/user = usr
			if(!user)
				return 1
			var/response = alert(user, "Really disable NTNet wireless? If your computer is connected wirelessly you won't be able to turn it back on! This will affect all connected wireless devices.", "NTNet shutdown", "Yes", "No")
			if(response == "Yes")
				GLOB.ntnet_global.setting_disabled = 1
			return 1
		if("purgelogs")
			. = 1
			if(GLOB.ntnet_global)
				GLOB.ntnet_global.purge_logs()
		if("updatemaxlogs")
			. = 1
			var/mob/user = usr
			var/logcount = text2num(input(user,"Enter amount of logs to keep in memory ([MIN_NTNET_LOGS]-[MAX_NTNET_LOGS]):"))
			if(GLOB.ntnet_global)
				GLOB.ntnet_global.update_max_log_count(logcount)
		if("toggle_function")
			. = 1
			if(!GLOB.ntnet_global)
				return 1
			GLOB.ntnet_global.toggle_function(text2num(params["id"]))

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!GLOB.ntnet_global)
		return
	var/list/data = get_header_data()

	data["ntnetstatus"] = GLOB.ntnet_global.check_function()
	data["ntnetrelays"] = GLOB.ntnet_global.relays.len
	data["idsstatus"] = GLOB.ntnet_global.intrusion_detection_enabled
	data["idsalarm"] = GLOB.ntnet_global.intrusion_detection_alarm

	data["config_softwaredownload"] = GLOB.ntnet_global.setting_softwaredownload
	data["config_peertopeer"] = GLOB.ntnet_global.setting_peertopeer
	data["config_communication"] = GLOB.ntnet_global.setting_communication
	data["config_systemcontrol"] = GLOB.ntnet_global.setting_systemcontrol

	data["ntnetlogs"] = list()

	for(var/i in GLOB.ntnet_global.logs)
		data["ntnetlogs"] += list(list("entry" = i))
	data["ntnetmaxlogs"] = GLOB.ntnet_global.setting_maxlogcount

	return data