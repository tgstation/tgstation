/*
 * # /datum/ntnet
 *
 * This class defines each network of the world.  Each root network is accessible by any device
 * on the same network but NOT accessible to any other "root" networks.  All normal devices only have
 * one network and one network_id.
 *
 * This thing replaces radio.  Think of wifi but better, bigger and bolder!  The idea is that any device
 * on a network can reach any other device on that same network if it knows the hardware_id.  You can also
 * search or broadcast to devices if you know what branch you wish.  That is to say you can broadcast to all
 * devices on "SS13.ATMOS.SCRUBBERS" to change the settings of all the scrubbers on the station or to
 * "SS13.AREA.FRED_HOME.SCRUBBERS" to all the scrubbers at one area.  However devices CANNOT communicate cross
 * networks normality.
 *
 */

/datum/ntnet
	/// The full network name for this network ex. SS13.ATMOS.SCRUBBERS
	var/network_id
	/// The network name part of this leaf ex ATMOS
	var/network_node_id
	/// All devices on this network.  ALL devices on this network, not just this branch.
	/// This list is shared between all leaf networks so we don't have to keep going to the
	/// parents on lookups.  It is an associated list of hardware_id AND tag_id's
	var/list/root_devices
	/// This lists has all the networks in this node.  Each name is fully qualified
	/// ie. SS13.ATMOS.SCRUBBERS, SS13.ATMOS.VENTS, etc
	var/list/networks
	/// All the devices on this branch of the network
	var/list/linked_devices
	/// Network children.  Associated list using the network_node_id of the child as the key
	var/list/children
	/// Parrnt of the network.  If this is null, we are a oot network
	var/datum/ntnet/parent


/*
 * Creates a new network
 *
 * Used for /datum/controller/subsystem/networks/proc/create_network so do not
 * call yourself as new doesn't do any checking itself
 *
 * Arguments:
 * * net_id - Fully qualified network id for this network
 * * net_part_id - sub part of a network if this is a child of P
 * * P - Parent network, this will be attached to that network.
 */
/datum/ntnet/New(net_id, net_part_id, datum/ntnet/P = null)
	linked_devices = list()
	children = list()
	network_id = net_id

	if(P)
		network_node_id = net_part_id
		parent = P
		parent.children[network_node_id] = src
		root_devices = parent.root_devices
		networks = parent.networks
		networks[network_id] = src
	else
		network_node_id = net_id
		parent = null
		networks = list()
		root_devices = linked_devices
		SSnetworks.root_networks[network_id] = src

	SSnetworks.networks[network_id] = src

	SSnetworks.add_log("Network was created: [network_id]")

	return ..()

/// A network should NEVER be deleted.  If you don't want to show it exists just check if its
/// empty
/datum/ntnet/Destroy()
	networks -= network_id
	if(children.len > 0 || linked_devices.len > 0)
		CRASH("Trying to delete a network with devices still in them")

	if(parent)
		parent.children.Remove(network_id)
		parent = null
	else
		SSnetworks.root_networks.Remove(network_id)

	SSnetworks.networks.Remove(network_id)

	root_devices = null
	networks = null
	network_node_id = null
	SSnetworks.add_log("Network was destroyed: [network_id]")
	network_id = null

	return ..()

/*
 * Collects all the devices on this branch of the network and maybe its
 * children
 *
 * Used for broadcasting, this will collect all the interfaces on this
 * network and by default everything below this branch.  Will return an
 * empty list if no devices were found
 *
 * Arguments:
 * * include_children - Include the children of all branches below this
 */
/datum/ntnet/proc/collect_interfaces(include_children=TRUE)
	if(!include_children || children.len == 0)
		return linked_devices.Copy()
	else
		/// Please no recursion.  Byond hates recursion
		var/list/devices = list()
		var/list/queue = list(src) // add ourselves
		while(queue.len)
			var/datum/ntnet/net = queue[queue.len--]
			if(net.children.len > 0)
				for(var/net_id in net.children)
					queue += networks[net_id]
			devices += net.linked_devices
		return devices


/*
 * Find if an interface exists on this network
 *
 * Used to look up a device on the network.
 *
 * Arguments:
 * * tag_or_hid - Ither the hardware id or the id_tag
 */
/datum/ntnet/proc/find_interface(tag_or_hid)
	return root_devices[tag_or_hid]

/**
 * Add this interface to this branch of the network.
 *
 * This will add a network interface to this branch of the network.
 * If the interface already exists on the network it will add it and
 * give the alias list in the interface this branch name.  If the interface
 * has an id_tag it will add that name to the root_devices for map lookup
 *
 * Arguments:
 * * interface - ntnet component of the device to add to the network
 */
/datum/ntnet/proc/add_interface(datum/component/ntnet_interface/interface)
	if(interface.network)
		/// If we are doing a hard jump to a new network, log it
		log_telecomms("The device {[interface.hardware_id]} is jumping networks from '[interface.network.network_id]' to '[network_id]'")
		interface.network.remove_interface(interface, TRUE)
	interface.network ||= src
	interface.alias[network_id] = src // add to the alias just to make removing easier.
	linked_devices[interface.hardware_id] = interface
	root_devices[interface.hardware_id] = interface
	if(interface.id_tag != null) // could be a type, never know
		root_devices[interface.id_tag] = interface

/*
 * Remove this interface from the network
 *
 * This will remove an interface from this network and null the network field on the
 * interface.  Be sure that add_interface is run as soon as posable as an interface MUST
 * have a network
 *
 * Arguments:
 * * interface - ntnet component of the device to remove to the network
 * * remove_all_alias - remove ALL references to this device on this network
 */
/datum/ntnet/proc/remove_interface(datum/component/ntnet_interface/interface, remove_all_alias=FALSE)
	if(!interface.alias[network_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to leave a '[network_id]'' when its on '[interface.network.network_id]'")
		return
	// just cashing it
	var/hardware_id = interface.hardware_id
	// Handle the quick case
	interface.alias.Remove(network_id)
	linked_devices.Remove(hardware_id)
	if(remove_all_alias)
		var/datum/ntnet/net
		for(var/id in interface.alias)
			net = interface.alias[id]
			net.linked_devices.Remove(hardware_id)

	// Now check if there are more than meets the eye
	if(interface.network == src || remove_all_alias)
		// Ok, so we got to remove this network, but if we have an alias we are still "on" the network
		// so we need to shift down to one of the other networks on the alias list.  If the alias list
		// is empty, fuck it and remove it from the network.
		if(interface.alias.len > 0)
			interface.network = interface.alias[1] // ... whatever is there.
		else
			// ok, hard remove from everything then
			root_devices.Remove(interface.hardware_id)
			if(interface.id_tag != null) // could be a type, never know
				root_devices.Remove(interface.id_tag)
			interface.network = null

/*
 * Move interface to another branch of the network
 *
 * This function is a lightweight way of moving an interface from one branch to another like a gps
 * device going from one area to another.  Target network MUST be this network or it will fail
 *
 * Arguments:
 * * interface - ntnet component of the device to move
 * * target_network - qualified network id to move to
 * * original_network - qualified network id from the original network if not this one
 */
/datum/ntnet/proc/move_interface(datum/component/ntnet_interface/interface, target_network, original_network = null)
	var/datum/ntnet/net = original_network == null ? src : networks[original_network]
	var/datum/ntnet/target = networks[target_network]
	if(!target || !net)
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) that is not on ([network_id])")
		return
	if(target.linked_devices[interface.hardware_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) it is already on.")
		return
	if(!net.linked_devices[interface.hardware_id])
		log_telecomms("The device {[interface.hardware_id]} is trying to move to a network ([target_network]) but its not on ([net.network_id]) ")
		return
	net.linked_devices.Remove(interface.hardware_id)
	target.linked_devices[interface.hardware_id] = interface
	interface.alias.Remove(net.network_id)
	interface.alias[target.network_id] = target



/datum/ntnet/station_root
	var/list/services_by_path = list() //type = datum/ntnet_service
	var/list/services_by_id = list() //id = datum/ntnet_service

	var/list/autoinit_service_paths = list() //typepaths


	var/list/available_station_software = list()
	var/list/available_antag_software = list()
	var/list/chat_channels = list()
	var/list/fileservers = list()

	// These only affect wireless. LAN (consoles) are unaffected since it would be possible to create scenario where someone turns off NTNet, and is unable to turn it back on since it refuses connections
	var/setting_softwaredownload = TRUE
	var/setting_peertopeer = TRUE
	var/setting_communication = TRUE
	var/setting_systemcontrol = TRUE
	var/setting_disabled = FALSE // Setting to 1 will disable all wireless, independently on relays status.

	var/intrusion_detection_enabled = TRUE // Whether the IDS warning system is enabled
	var/intrusion_detection_alarm = FALSE // Set when there is an IDS warning due to malicious (antag) software.

// If new NTNet datum is spawned, it replaces the old one.
/datum/ntnet/station_root/New(root_name)
	. = ..()
	SSnetworks.add_log("NTNet logging system activated for [root_name]")




#ifdef NTNET_SERVICE
/datum/ntnet/station_root/Destroy()
	for(var/i in services_by_id)
		var/S = i
		S.disconnect(src, TRUE)
	return ..()


/datum/ntnet/station_root/proc/find_service_id(id)
	return services_by_id[id]

/datum/ntnet/station_root/proc/find_service_path(path)
	return services_by_path[path]

/datum/ntnet/station_root/proc/register_service(datum/ntnet_service/S)
	if(!istype(S))
		return FALSE
	if(services_by_path[S.type] || services_by_id[S.id])
		return FALSE
	services_by_path[S.type] = S
	services_by_id[S.id] = S
	return TRUE

/datum/ntnet/station_root/proc/unregister_service(datum/ntnet_service/S)
	if(!istype(S))
		return FALSE
	services_by_path -= S.type
	services_by_id -= S.id
	return TRUE

/datum/ntnet/station_root/proc/create_service(type)
	var/datum/ntnet_service/S = new type
	if(!istype(S))
		return FALSE
	. = S.connect(src)
	if(!.)
		qdel(S)

/datum/ntnet/station_root/proc/destroy_service(type)
	var/datum/ntnet_service/S = find_service_path(type)
	if(!istype(S))
		return FALSE
	. = S.disconnect(src)
	if(.)
		qdel(src)

/datum/ntnet/station_root/proc/process_data_transmit(datum/component/ntnet_interface/sender, datum/netdata/data)
	if(..())
		for(var/i in services_by_id)
			var/datum/ntnet_service/serv = services_by_id[i]
			serv.ntnet_intercept(data, src, sender)
		return TRUE
#endif

// Checks whether NTNet operates. If parameter is passed checks whether specific function is enabled.
/datum/ntnet/station_root/proc/check_function(specific_action = 0)
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
/datum/ntnet/station_root/proc/build_software_lists()
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
/datum/ntnet/station_root/proc/find_ntnet_file_by_name(filename)
	for(var/N in available_station_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P
	for(var/N in available_antag_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P

/datum/ntnet/station_root/proc/get_chat_channel_by_id(id)
	for(var/datum/ntnet_conversation/chan in chat_channels)
		if(chan.id == id)
			return chan

// Resets the IDS alarm
/datum/ntnet/station_root/proc/resetIDS()
	intrusion_detection_alarm = FALSE

/datum/ntnet/station_root/proc/toggleIDS()
	resetIDS()
	intrusion_detection_enabled = !intrusion_detection_enabled


/datum/ntnet/station_root/proc/toggle_function(function)
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



/datum/ntnet/station_root/proc/register_map_supremecy() //called at map init to make this what station networks use.
	for(var/obj/machinery/ntnet_relay/R in GLOB.machines)
		SSnetworks.relays.Add(R)
		R.NTNet = src
