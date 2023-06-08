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
	switch(action)
		if("resetIDS")
			SSmodular_computers.intrusion_detection_alarm = FALSE
			return TRUE
		if("toggleIDS")
			SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled
			return TRUE
		if("toggle_relay")
			var/obj/machinery/ntnet_relay/target_relay = locate(params["ref"]) in GLOB.ntnet_relays
			if(!istype(target_relay))
				return
			target_relay.set_relay_enabled(!target_relay.relay_enabled)
			return TRUE
		if("purgelogs")
			SSmodular_computers.purge_logs()
			return TRUE
		if("toggle_mass_pda")
			var/obj/item/modular_computer/target_tablet = locate(params["ref"]) in GLOB.TabletMessengers
			if(!istype(target_tablet))
				return
			for(var/datum/computer_file/program/messenger/messenger_app in target_tablet.stored_files)
				messenger_app.spam_mode = !messenger_app.spam_mode
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	var/list/data = list()

	data["ntnetrelays"] = list()
	for(var/obj/machinery/ntnet_relay/relays as anything in GLOB.ntnet_relays)
		var/list/relay_data = list()
		relay_data["is_operational"] = !!relays.is_operational
		relay_data["name"] = relays.name
		relay_data["ref"] = REF(relays)

		data["ntnetrelays"] += list(relay_data)

	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["ntnetlogs"] = list()
	for(var/i in SSmodular_computers.logs)
		data["ntnetlogs"] += list(list("entry" = i))

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
