#define NETWORK_TO_STRING(NETWORK, NODE) "[NETWORK].[NODE].[PORT]"
/* This is the ntnet!  All network names must be unique.  While, in theory, they can have the same name and
be under a diffrent parrent, it means we have to implment a proper routing protocal instad of just having a
big list of networks to search under.  This also means evey device must know its network name and hardware id
to find one another.  We also can query an entire network for devices so this works similarly to filter in
the old radio.

Now port is intresting.  Right now its a list of static data.  So if something querys a port and we have
it in the list, we can either have it call a call back (not implmented) or return a list of data.

Port 0 will be the "info" requiest.  It will return the obj.name, obj.type.  More data?
Any other port will just fall down

PS - This is just a temp explitaion, I am horiable on typing and documentation because of my dislex ass
*/

/datum/ntnet
	// Amount of logs the system tries to keep in memory. Keep below 999 to prevent byond from acting weirdly.
	// High values make displaying logs much laggier.
	var/static/setting_maxlogcount = 100
	var/static/list/relays = list()
	var/static/list/logs = list()

	// special case for network_id being null
	// We are in general subspace, where all we are is a list of networks
	//
	var/network_id
	// the string of this tree
	var/network_tree
	var/list/linked_devices
	var/list/children
	var/datum/ntnet/parent

/datum/ntnet/New(network_id, datum/ntnet/parent = null)
	src.linked_devices = list()
	src.network_id = network_id
	if(parent)
		src.parent = parent
		LAZYADDASSOC(src.parent.children, network_id, src)
	else
		src.parent = null
		src.children = null

	network_tree = SSnetworks.create_network_tree_string(src)
	SSnetworks.networks[network_tree] = src




/datum/ntnet/Destroy()
	if(length(linked_devices) > 0)
		debug_world_log("Network [network_id] being deleted with linked devices.  Disconnecting Devices")
		for(var/hid in linked_devices)
			var/datum/component/ntnet_interface/device = linked_devices[hid]
			device.network = null	// we just need to clear the refrence
		linked_devices = null

	if(length(children))
		debug_world_log("Network [network_id] being deleted with kids.  Killing the children")
		for(var/child in children)
			qdel(children[child])
		children = null

	if(parent)
		parent.children.Remove(network_id)
		parent = null

	SSnetworks.networks.Remove(network_tree)
	return ..()

// creates a network as a child of this network
/datum/ntnet/proc/find_child(child_id, create_if_not_found = FALSE)
	var/datum/ntnet/net = children[child_id]
	if(net)
		return net
	if(create_if_not_found)
		return new/datum/ntnet(child_id, network_id)


/datum/ntnet/proc/interface_connect(datum/component/ntnet_interface/device)
	if(device.network)
		device.network.interface_disconnect(device)
	linked_devices[device.hardware_id] = device
	device.network = src

/datum/ntnet/proc/interface_disconnect(datum/component/ntnet_interface/device)
	linked_devices.Remove(device.hardware_id)
	device.network = null


/datum/ntnet/proc/check_relay_operation(zlevel=0)	//can be expanded later but right now it's true/false.
	for(var/i in relays)
		var/obj/machinery/ntnet_relay/n = i
		if(zlevel && n.z != zlevel)
			continue
		if(n.is_operational)
			return TRUE
	return FALSE


/datum/ntnet/proc/process_data_transmit(datum/component/ntnet_interface/sender, datum/netdata/data)
	if(!check_relay_operation()) // mabye hold of on relays and refactor them as "routers"
		return FALSE
	var/datum/component/ntnet_interface/target
	data.sender_network = sender.network.network_id
	data.sender_id = sender.hardware_id
	log_data_transfer(data)
	if(istext(data.receiver_id)) // quick send
		if(SSnetworks.network_tag_to_hardware_id[data.receiver_id])
			data.receiver_id = SSnetworks.network_tag_to_hardware_id[data.receiver_id]
		target = SSnetworks.interfaces_by_hardware_id[data.receiver_id ]
		if(!QDELETED(target)) // Do we need this or not? alot of async goes around
			target.__network_receive(data)

	var/list/targets = data.receiver_id == null ?  SSnetworks.collect_interfaces(network_id) : data.receiver_id
	if(targets)
		for(var/hid in targets)
			target = SSnetworks.interfaces_by_hardware_id[hid]
			if(!QDELETED(target)) // Do we need this or not? alot of async goes around
				target.__network_receive(data)


/datum/ntnet/proc/log_data_transfer(datum/netdata/data)
	logs += "[station_time_timestamp()] - [data.generate_netlog()]"
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len - setting_maxlogcount, 0)

// Simplified logging: Adds a log. log_string is mandatory parameter, source is optional.
/datum/ntnet/proc/add_log(log_string, obj/item/computer_hardware/network_card/source = null)
	var/log_text = "[station_time_timestamp()](network_id) - "
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
/datum/ntnet/station/New(network_id = STATION_NETWORK_ROOT)
	..()
	build_software_lists()
	add_log("NTNet logging system activated.")


/datum/ntnet/station/syndicate/New(network_id = SYNDICATE_NETWORK_ROOT)
	..()
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
