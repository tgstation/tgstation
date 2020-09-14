

#define ADDRESS_TO_STRING(NETWORK,NODE,PORT) "[NETWORK].[NODE].[PORT]"


/datum/ntnet
	// Amount of logs the system tries to keep in memory. Keep below 999 to prevent byond from acting weirdly.
	// High values make displaying logs much laggier.
	var/static/setting_maxlogcount = 100
	var/static/list/relays = list()
	var/static/list/logs = list()

	var/network_id
	var/list/linked_devices
	var/list/forward_lookup
	var/list/reverse_lookup
	var/datum/ntnet/parent
	var/isolated = FALSE // isolated network, so we only can get hardware on this network, not parents

/datum/ntnet/New(network_id, datum/ntnet/parent = null)
	src.linked_devices = list()
	src.network_id = network_id
	if(parent)
		src.forward_lookup = parent.forward_lookup
		src.reverse_lookup = parent.reverse_lookup
		src.parent = parent
	else
		src.forward_lookup = list()
		src.reverse_lookup = list()
		src.parent = null

	if(!SSnetworks.register_network(src))
		stack_trace("Network [type] with ID [network_id] failed to register and has been deleted.")
		qdel(src)

/datum/ntnet/Destroy()
	if(src.parent)
		var/name
		for(var/hid in linked_devices)
			name = reverse_lookup[hid]
			reverse_lookup.Remove(hid)
			forward_lookup.Remove(name)
		src.parent = null
	linked_devices = null
	reverse_lookup = null
	forward_lookup = null

	return ..()

/datum/ntnet/proc/find_by_hid(hid)
	var/datum/component/ntnet_interface/thing = linked_devices[hid]
	if(!thing && parent && !isolated)
		thing = parent.find_by_hid(hid)
	return thing

/datum/ntnet/proc/find_by_name(name)
	var/hid = forward_lookup[name]
	if(hid)
		return find_by_hid(hid)

/datum/ntnet/proc/interface_connect(datum/component/ntnet_interface/device)
	var/hid = device.hardware_id
	if(device.network)
		interface_disconnect(device)
	linked_devices[hid] = device
	device.network = src

/datum/ntnet/proc/interface_disconnect(datum/component/ntnet_interface/device)
	var/hid = device.hardware_id
	linked_devices.Remove(hid)
	var/name = reverse_lookup[hid]
	if(name)
		reverse_lookup.Remove(hid)
		forward_lookup.Remove(name)
	device.network = null

/datum/ntnet/proc/add_lookup(hardware_id, name)
	if(linked_devices[hardware_id])
		if(!forward_lookup[name])
			forward_lookup[name] = hardware_id
			reverse_lookup[hardware_id] = name
			return TRUE

/datum/ntnet/proc/remove_lookup(name)
	var/id = forward_lookup[name]
	if(id)
		reverse_lookup.Remove(id)
		forward_lookup.Remove(name)
		return TRUE


/datum/ntnet/proc/check_relay_operation(zlevel)	//can be expanded later but right now it's true/false.
	for(var/i in relays)
		var/obj/machinery/ntnet_relay/n = i
		if(zlevel && n.z != zlevel)
			continue
		if(n.is_operational)
			return TRUE
	return FALSE


/datum/ntnet/proc/process_data_transmit(datum/component/ntnet_interface/sender, datum/netdata/data)
	if(!check_relay_operation())
		return FALSE
	data.network = src
	log_data_transfer(data)
	var/list/datum/component/ntnet_interface/receiving = list()
	if((length(data.recipient_ids) == 1 && data.recipient_ids[1] == NETWORK_BROADCAST_ID) || data.recipient_ids == NETWORK_BROADCAST_ID)
		data.broadcast = TRUE
		for(var/hid in src.linked_devices)
			receiving.Add(src.linked_devices[hid])
	else
		for(var/hid in data.recipient_ids)
			var/datum/component/ntnet_interface/receiver = find_by_hid(hid)
			receiving.Add(receiver)

	for(var/i in 1 to receiving.len)
		var/datum/component/ntnet_interface/receiver = receiving[i]
		if(receiver)
			receiver.__network_receive(data)

	return TRUE


/datum/ntnet/proc/log_data_transfer(datum/netdata/data)
	logs += "[station_time_timestamp()] - [data.generate_netlog()]"
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len - setting_maxlogcount, 0)
	return

// Simplified logging: Adds a log. log_string is mandatory parameter, source is optional.
/datum/ntnet/proc/add_log(log_string, obj/item/computer_hardware/network_card/source = null)
	var/log_text = "[station_time_timestamp()] - "
	if(source)
		log_text += "[source.get_network_tag()] - "
	else
		log_text += "*SYSTEM* - "
	log_text += log_string
	logs.Add(log_text)

	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len-setting_maxlogcount,0)


// Removes all logs
/datum/ntnet/proc/purge_logs()
	logs = list()
	add_log("-!- LOGS DELETED BY SYSTEM OPERATOR -!-")

// Updates maximal amount of stored logs. Use this instead of setting the number, it performs required checks.
/datum/ntnet/proc/update_max_log_count(lognumber)
	if(!lognumber)
		return FALSE
	// Trim the value if necessary
	lognumber = max(MIN_NTNET_LOGS, min(lognumber, MAX_NTNET_LOGS))
	setting_maxlogcount = lognumber
	add_log("Configuration Updated. Now keeping [setting_maxlogcount] logs in system memory.")

/datum/ntnet/station
	var/list/services_by_path = list()					//type = datum/ntnet_service
	var/list/services_by_id = list()					//id = datum/ntnet_service

	var/list/autoinit_service_paths = list()			//typepaths


	var/list/available_station_software = list()
	var/list/available_antag_software = list()
	var/list/chat_channels = list()
	var/list/fileservers = list()

	// These only affect wireless. LAN (consoles) are unaffected since it would be possible to create scenario where someone turns off NTNet, and is unable to turn it back on since it refuses connections
	var/setting_softwaredownload = TRUE
	var/setting_peertopeer = TRUE
	var/setting_communication = TRUE
	var/setting_systemcontrol = TRUE
	var/setting_disabled = FALSE					// Setting to 1 will disable all wireless, independently on relays status.

	var/intrusion_detection_enabled = TRUE 		// Whether the IDS warning system is enabled
	var/intrusion_detection_alarm = FALSE			// Set when there is an IDS warning due to malicious (antag) software.

// If new NTNet datum is spawned, it replaces the old one.
/datum/ntnet/station/New()
	..("SS13-NTNET")
	build_software_lists()
	add_log("NTNet logging system activated.")

// not sure if we want service to work as it is, hold off till we get machines working

#ifdef NTNET_SERVICE
/datum/ntnet/station/Destroy()
	for(var/i in services_by_id)
		var/S = i
		S.disconnect(src, TRUE)
	return ..()


/datum/ntnet/station/proc/find_service_id(id)
	return services_by_id[id]

/datum/ntnet/station/proc/find_service_path(path)
	return services_by_path[path]

/datum/ntnet/station/proc/register_service(datum/ntnet_service/S)
	if(!istype(S))
		return FALSE
	if(services_by_path[S.type] || services_by_id[S.id])
		return FALSE
	services_by_path[S.type] = S
	services_by_id[S.id] = S
	return TRUE

/datum/ntnet/station/proc/unregister_service(datum/ntnet_service/S)
	if(!istype(S))
		return FALSE
	services_by_path -= S.type
	services_by_id -= S.id
	return TRUE

/datum/ntnet/station/proc/create_service(type)
	var/datum/ntnet_service/S = new type
	if(!istype(S))
		return FALSE
	. = S.connect(src)
	if(!.)
		qdel(S)

/datum/ntnet/station/proc/destroy_service(type)
	var/datum/ntnet_service/S = find_service_path(type)
	if(!istype(S))
		return FALSE
	. = S.disconnect(src)
	if(.)
		qdel(src)

/datum/ntnet/station/proc/process_data_transmit(datum/component/ntnet_interface/sender, datum/netdata/data)
	if(..())
		for(var/i in services_by_id)
			var/datum/ntnet_service/serv = services_by_id[i]
			serv.ntnet_intercept(data, src, sender)
		return TRUE
#endif

// Checks whether NTNet operates. If parameter is passed checks whether specific function is enabled.
/datum/ntnet/station/proc/check_function(specific_action = 0)
	if(!relays || !relays.len) // No relays found. NTNet is down
		return FALSE

	// Check all relays. If we have at least one working relay, network is up.
	if(!check_relay_operation())
		return FALSE

	if(setting_disabled)
		return FALSE

	switch(specific_action)
		if(NTNET_SOFTWAREDOWNLOAD)
			return setting_softwaredownload
		if(NTNET_PEERTOPEER)
			return setting_peertopeer
		if(NTNET_COMMUNICATION)
			return setting_communication
		if(NTNET_SYSTEMCONTROL)
			return setting_systemcontrol
	return TRUE

// Builds lists that contain downloadable software.
/datum/ntnet/station/proc/build_software_lists()
	available_station_software = list()
	available_antag_software = list()
	for(var/F in typesof(/datum/computer_file/program))
		var/datum/computer_file/program/prog = new F
		// Invalid type (shouldn't be possible but just in case), invalid filetype (not executable program) or invalid filename (unset program)
		if(!prog || prog.filename == "UnknownProgram" || prog.filetype != "PRG")
			continue
		// Check whether the program should be available for station/antag download, if yes, add it to lists.
		if(prog.available_on_ntnet)
			available_station_software.Add(prog)
		if(prog.available_on_syndinet)
			available_antag_software.Add(prog)

// Attempts to find a downloadable file according to filename var
/datum/ntnet/station/proc/find_ntnet_file_by_name(filename)
	for(var/N in available_station_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P
	for(var/N in available_antag_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P

/datum/ntnet/station/proc/get_chat_channel_by_id(id)
	for(var/datum/ntnet_conversation/chan in chat_channels)
		if(chan.id == id)
			return chan

// Resets the IDS alarm
/datum/ntnet/station/proc/resetIDS()
	intrusion_detection_alarm = FALSE

/datum/ntnet/station/proc/toggleIDS()
	resetIDS()
	intrusion_detection_enabled = !intrusion_detection_enabled


/datum/ntnet/station/proc/toggle_function(function)
	if(!function)
		return
	function = text2num(function)
	switch(function)
		if(NTNET_SOFTWAREDOWNLOAD)
			setting_softwaredownload = !setting_softwaredownload
			add_log("Configuration Updated. Wireless network firewall now [setting_softwaredownload ? "allows" : "disallows"] connection to software repositories.")
		if(NTNET_PEERTOPEER)
			setting_peertopeer = !setting_peertopeer
			add_log("Configuration Updated. Wireless network firewall now [setting_peertopeer ? "allows" : "disallows"] peer to peer network traffic.")
		if(NTNET_COMMUNICATION)
			setting_communication = !setting_communication
			add_log("Configuration Updated. Wireless network firewall now [setting_communication ? "allows" : "disallows"] instant messaging and similar communication services.")
		if(NTNET_SYSTEMCONTROL)
			setting_systemcontrol = !setting_systemcontrol
			add_log("Configuration Updated. Wireless network firewall now [setting_systemcontrol ? "allows" : "disallows"] remote control of station's systems.")



/datum/ntnet/station/proc/register_map_supremecy()					//called at map init to make this what station networks use.
	for(var/obj/machinery/ntnet_relay/R in GLOB.machines)
		relays.Add(R)
		R.NTNet = src
