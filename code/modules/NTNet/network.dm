/* This is the ntnet!  All network names must be unique.  While, in theory, they can have the same name and
be under a different parent, it means we have to impellent a proper routing protocol instead of just having a
big list of networks to search under.  This also means every device must know its network name and hardware id
to find one another.  We also can query an entire network for devices so this works similarly to filter in
the old radio.

Now port is interesting.  Right now its a list of static data.  So if something querys a port and we have
it in the list, we can either have it call a call back (not implemented) or return a list of data.

Port 0 will be the "info" request.  It will return the obj.name, obj.type.  More data?
Any other port will just fall down

PS - This is just a temp explanation, I am horrible on typing and documentation
*/

/datum/ntnet
	/// The full network name for this network ex. SS13.ATMOS.SCRUBBERS
	var/network_id
	/// The network name part of this leaf ex ATMOS
	var/network_node_id
	// the string of this tree
	// All devices that can be found on this network.  It is shared with all the children so we
	// don't have to do a full tree transverse to find a single network item.
	var/list/root_devices
	// This lists has all the networks in this node.  they all should be like ATMOS, ATMOS.AIRALARM, ATMOS.SCRUBBER, etc
	var/list/networks
	/// devices on this leaf
	var/list/linked_devices
	var/list/children
	var/datum/ntnet/parent

/datum/ntnet/New(net_id, datum/ntnet/P = null)
	linked_devices = list()
	children = list()
	network_id = net_id
	if(P)
		parent = P
		parent.children[network_id] = src
		root_devices = parent.root_devices
		networks = parent.networks
		network_node_id = findtext(net_id, @"[^\.]+$")
	else
		parent = null
		networks = list()
		root_devices = list()
		network_node_id = net_id

	SSnetworks.networks[network_id] = src

/datum/ntnet/vv_edit_var(var_name)
	. = ..()
	//switch (var_name)
	//	if (NAMEOF(src, cyclelinkeddir))
	//		cyclelinkairlock()


// we shouldn't ever EVER delete networks.  ESPECIALLY if there are devices in them
/datum/ntnet/Destroy()
	if(children.len > 0 || linked_devices.len > 0)
		CRASH("Trying to delete a network with devices still in them")

	if(parent)
		parent.children.Remove(network_id)
		parent = null

	SSnetworks.networks.Remove(network_id)
	return ..()

// collect all interfaces as well as children.  It looks wonky so not
// to use recursion
/datum/ntnet/proc/collect_interfaces(include_children=TRUE)
	var/list/devices
	if(children.len == 0 || !include_children)
		devices = linked_devices
	else
		devices = list()
		var/list/queue = list(src)
		while(queue.len)
			var/datum/ntnet/net = queue[queue.len--]
			if(net.children)
				for(var/net_id in net.children)
					queue += networks[net_id]
			devices += net.linked_devices
	return devices

/// find a network
/datum/ntnet/proc/find_network(child_id, create_if_not_found = FALSE)
	var/datum/ntnet/net = networks[child_id]
	if(net)
		return net
	// if the first part of the child_id exists in this network_id
	// then we can create it as a child
	if(create_if_not_found && findtext(network_id,child_id) == 1)
		return SSnetworks.create_network_simple(child_id)


/datum/ntnet/proc/interface_find(tag_or_hid)
	return root_devices[tag_or_hid]




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
/datum/ntnet/station/New(netname = STATION_NETWORK_ROOT, datum/ntnet/parent=null)
	. = ..(netname,  parent)
	build_software_lists()
	SSnetworks.add_log("NTNet logging system activated.")



/datum/ntnet/station/syndicate/New(network_id = SYNDICATE_NETWORK_ROOT)
	..()
	build_software_lists()
	SSnetworks.add_log("NTNet logging system activated.")
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
	if(!SSnetworks.relays || !SSnetworks.relays.len) // No relays found. NTNet is down
		return FALSE

	// Check all relays. If we have at least one working relay, network is up.
	if(!SSnetworks.check_relay_operation())
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
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_softwaredownload ? "allows" : "disallows"] connection to software repositories.")
		if(NTNET_PEERTOPEER)
			setting_peertopeer = !setting_peertopeer
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_peertopeer ? "allows" : "disallows"] peer to peer network traffic.")
		if(NTNET_COMMUNICATION)
			setting_communication = !setting_communication
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_communication ? "allows" : "disallows"] instant messaging and similar communication services.")
		if(NTNET_SYSTEMCONTROL)
			setting_systemcontrol = !setting_systemcontrol
			SSnetworks.add_log("Configuration Updated. Wireless network firewall now [setting_systemcontrol ? "allows" : "disallows"] remote control of station's systems.")



/datum/ntnet/station/proc/register_map_supremecy()					//called at map init to make this what station networks use.
	for(var/obj/machinery/ntnet_relay/R in GLOB.machines)
		SSnetworks.relays.Add(R)
		R.NTNet = src
