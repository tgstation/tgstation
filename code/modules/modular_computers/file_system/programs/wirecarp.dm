/datum/computer_file/program/ntnetmonitor
	filename = "wirecarp"
	filedesc = "WireCarp"
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_open_overlay = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 12
	run_access = list(ACCESS_NETWORK) //NETWORK CONTROL IS A MORE SECURE PROGRAM.
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	tgui_id = "NtosNetMonitor"
	program_icon = "network-wired"
	circuit_comp_type = /obj/item/circuit_component/mod_program/ntnetmonitor

/datum/computer_file/program/ntnetmonitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("resetIDS")
			SSmodular_computers.intrusion_detection_alarm = FALSE
			return TRUE
		if("toggleIDS")
			SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled
			return TRUE
		if("toggle_relay")
			var/obj/machinery/ntnet_relay/target_relay = locate(params["ref"]) in SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay)
			if(!istype(target_relay))
				return
			target_relay.set_relay_enabled(!target_relay.relay_enabled)
			return TRUE
		if("purgelogs")
			SSmodular_computers.purge_logs()
			return TRUE
		if("toggle_mass_pda")
			if(!(params["ref"] in GLOB.pda_messengers))
				return
			var/datum/computer_file/program/messenger/target_messenger = GLOB.pda_messengers[params["ref"]]
			target_messenger.spam_mode = !target_messenger.spam_mode
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	var/list/data = list()

	data["ntnetrelays"] = list()
	for(var/obj/machinery/ntnet_relay/relays as anything in SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay))
		var/list/relay_data = list()
		relay_data["is_operational"] = !!relays.is_operational
		relay_data["name"] = relays.name
		relay_data["ref"] = REF(relays)

		data["ntnetrelays"] += list(relay_data)

	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["ntnetlogs"] = list()
	for(var/i in SSmodular_computers.modpc_logs)
		data["ntnetlogs"] += list(list("entry" = i))

	data["tablets"] = list()
	for(var/datum/computer_file/program/messenger/app as anything in GLOB.pda_messengers_by_name)
		var/obj/item/modular_computer/pda = app.computer

		var/list/tablet_data = list()
		tablet_data["enabled_spam"] = app.spam_mode
		tablet_data["name"] = pda.saved_identification
		tablet_data["ref"] = REF(app)

		data["tablets"] += list(tablet_data)

	return data

/obj/item/circuit_component/mod_program/ntnetmonitor
	associated_program = /datum/computer_file/program/ntnetmonitor
	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL
	///The stored NTnet relay or PDA to be used as the target of triggers
	var/datum/port/input/target
	///Sets `intrusion_detection_alarm` when triggered
	var/datum/port/input/toggle_ids
	///Toggles the target ntnet relay on/off when triggered
	var/datum/port/input/toggle_relay
	///Purges modpc logs when triggered
	var/datum/port/input/purge_logs
	///Toggles the spam mode of the target PDA when triggered
	var/datum/port/input/toggle_mass_pda
	///Toggle mime mode of the target PDA when triggered
	var/datum/port/input/toggle_mime_mode
	///Returns a list of all PDA Messengers when the "Get Messengers" input is pinged
	var/datum/port/output/all_messengers
	///See above
	var/datum/port/input/get_pdas

/obj/item/circuit_component/mod_program/ntnetmonitor/populate_ports()
	. = ..()
	target = add_input_port("Target Messenger/Relay", PORT_TYPE_ATOM)
	toggle_ids = add_input_port("Toggle IDS Status", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_ids))
	toggle_relay = add_input_port("Toggle NTnet Relay", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_relay))
	purge_logs = add_input_port("Purge Logs", PORT_TYPE_SIGNAL, trigger = PROC_REF(purge_logs))
	toggle_mass_pda = add_input_port("Toggle Mass Messenger", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_pda_stuff))
	toggle_mime_mode = add_input_port("Toggle Mime Mode", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_pda_stuff))
	get_pdas = add_input_port("Get PDAs", PORT_TYPE_SIGNAL, trigger = PROC_REF(get_pdas))
	all_messengers = add_output_port("List of PDAs", PORT_TYPE_LIST(PORT_TYPE_ATOM))

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/get_pdas(datum/port/port)
	var/list/computers_with_messenger = list()
	for(var/messenger_ref as anything in GLOB.pda_messengers)
		var/datum/computer_file/program/messenger/messenger = GLOB.pda_messengers[messenger_ref]
		computers_with_messenger |= WEAKREF(messenger.computer)
	all_messengers.set_output(computers_with_messenger)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_ids(datum/port/port)
	SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_relay(datum/port/port)
	var/obj/machinery/ntnet_relay/target_relay = target.value
	if(!istype(target_relay))
		return
	target_relay.set_relay_enabled(!target_relay.relay_enabled)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/purge_logs(datum/port/port)
	SSmodular_computers.purge_logs()

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_pda_stuff(datum/port/port)
	var/obj/item/modular_computer/computer = target.value
	if(!istype(computer))
		return
	var/datum/computer_file/program/messenger/target_messenger = locate() in computer.stored_files
	if(isnull(target_messenger))
		return
	if(COMPONENT_TRIGGERED_BY(toggle_mass_pda, port))
		target_messenger.spam_mode = !target_messenger.spam_mode
	if(COMPONENT_TRIGGERED_BY(toggle_mime_mode, port))
		target_messenger.mime_mode = !target_messenger.mime_mode
