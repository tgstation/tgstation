SUBSYSTEM_DEF(modular_computers)
	name = "Modular Computers"
	flags = SS_NO_FIRE

	///List of all programs available to download from the NTNet store.
	var/list/available_station_software = list()
	///List of all programs that can be downloaded from an emagged NTNet store.
	var/list/available_antag_software = list()
	///List of all chat channels created by Chat Client.
	var/list/chat_channels = list()

	///Boolean on whether downloading software works.
	var/setting_softwaredownload = TRUE
	///Boolean on whether downloading communication apps like the Chat client works.
	var/setting_communication = TRUE

	///Boolean on whether the IDS warning system is enabled
	var/intrusion_detection_enabled = TRUE
	///Boolean to show a message warning if there's an active intrusion for Wirecarp users.
	var/intrusion_detection_alarm = FALSE

	///List of all available NTNet relays.
	var/list/obj/machinery/ntnet_relay/ntnet_relays = list()

/datum/controller/subsystem/modular_computers/Initialize()
	build_software_lists()
	initialized = TRUE
	return SS_INIT_SUCCESS

///Finds all downloadable programs and adds them to their respective downloadable list.
/datum/controller/subsystem/modular_computers/proc/build_software_lists()
	for(var/datum/computer_file/program/prog as anything in subtypesof(/datum/computer_file/program))
		// Has no TGUI file so is not meant to be a downloadable thing.
		if(!initial(prog.tgui_id))
			continue
		prog = new prog

		if(prog.available_on_ntnet)
			available_station_software.Add(prog)
		if(prog.available_on_syndinet)
			available_antag_software.Add(prog)

///Checks if at least one ntnet relay is functional.
/datum/controller/subsystem/modular_computers/proc/check_relay_operation()
	for(var/obj/machinery/ntnet_relay/relays as anything in ntnet_relays)
		if(!relays.is_operational)
			continue
		return TRUE
	return FALSE

/datum/controller/subsystem/modular_computers/proc/toggle_function(function)
	if(!function)
		return
	function = text2num(function)
	switch(function)
		if(NTNET_SOFTWAREDOWNLOAD)
			setting_softwaredownload = !setting_softwaredownload
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_softwaredownload ? "allows" : "disallows"] connection to software repositories.")
		if(NTNET_COMMUNICATION)
			setting_communication = !setting_communication
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_communication ? "allows" : "disallows"] instant messaging and similar communication services.")

///Checks whether NTNet is available for a specific function, checking NTNet relays and shutdowns. If none is passed, none is needed.
/datum/controller/subsystem/modular_computers/proc/check_function(specific_action = NONE)
	// No relays found. NTNet is down
	if(!length(ntnet_relays))
		return FALSE
	// Check all relays. If we have at least one working relay, network is up.
	if(!check_relay_operation())
		return FALSE

	switch(specific_action)
		if(NTNET_SOFTWAREDOWNLOAD)
			return setting_softwaredownload
		if(NTNET_COMMUNICATION)
			return setting_communication
	return TRUE

///Attempts to find a new file through searching the available stores with its name.
/datum/controller/subsystem/modular_computers/proc/find_ntnet_file_by_name(filename)
	for(var/datum/computer_file/program/programs as anything in available_station_software + available_antag_software)
		if(filename == programs.filename)
			return programs

///Attempts to find a chatorom using the ID of the channel.
/datum/controller/subsystem/modular_computers/proc/get_chat_channel_by_id(id)
	for(var/datum/ntnet_conversation/chan as anything in chat_channels)
		if(chan.id == id)
			return chan
