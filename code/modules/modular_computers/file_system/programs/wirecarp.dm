/datum/computer_file/program/ntnetmonitor
	filename = "wirecarp"
	filedesc = "WireCarp"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	requires_ntnet = TRUE
	required_access = list(ACCESS_NETWORK) //NETWORK CONTROL IS A MORE SECURE PROGRAM.
	available_on_ntnet = TRUE
	tgui_id = "NtosNetMonitor"
	program_icon = "network-wired"

/datum/computer_file/program/ntnetmonitor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("resetIDS")
			SSmodular_computers.intrusion_detection_alarm = FALSE
			return TRUE
		if("toggleIDS")
			SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled
			return TRUE
		if("purgelogs")
			SSnetworks.purge_logs()
			return TRUE
		if("updatemaxlogs")
			var/logcount = params["new_number"]
			SSnetworks.update_max_log_count(logcount)
			return TRUE
		if("toggle_function")
			SSmodular_computers.toggle_function(text2num(params["id"]))
			return TRUE
		if("toggle_mass_pda")
			var/obj/item/modular_computer/target_tablet = locate(params["ref"]) in GLOB.TabletMessengers
			if(!istype(target_tablet))
				return
			for(var/datum/computer_file/program/messenger/messenger_app in target_tablet.stored_files)
				messenger_app.spam_mode = !messenger_app.spam_mode

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	var/list/data = get_header_data()

	data["ntnetstatus"] = SSmodular_computers.check_function()
	data["ntnetrelays"] = SSmodular_computers.ntnet_relays.len

	data["config_softwaredownload"] = SSmodular_computers.setting_softwaredownload
	data["config_communication"] = SSmodular_computers.setting_communication

	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["ntnetlogs"] = list()
	for(var/i in SSnetworks.logs)
		data["ntnetlogs"] += list(list("entry" = i))
	data["ntnetmaxlogs"] = SSnetworks.setting_maxlogcount

	data["tablets"] = list()
	for(var/obj/item/modular_computer/messenger as anything in GetViewableDevices())
		var/list/tablet_data = list()
		if(messenger.saved_identification)
			for(var/datum/computer_file/program/messenger/messenger_app in computer.stored_files)
				tablet_data["enabled_spam"] += messenger_app.spam_mode

			tablet_data["name"] += messenger.saved_identification
			tablet_data["ref"] += REF(messenger)

		data["tablets"] += list(tablet_data)

	return data

/datum/computer_file/program/ntnetmonitor/ui_static_data(mob/user)
	var/list/data = ..()
	data["minlogs"] = MIN_NTNET_LOGS
	data["maxlogs"] = MAX_NTNET_LOGS
	return data
