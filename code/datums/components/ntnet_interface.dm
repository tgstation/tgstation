/datum/proc/ntnet_receive(datum/netdata/data)
	return


/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data)


/datum/component/ntnet_interface
	var/hardware_id						//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/network_tag = null  			// named tag for looking up on mapping objects
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/regestered_scokets 		// list of connections

/datum/component/ntnet_interface/Initialize(network_name,network_tag)			//Don't force ID unless you know what you're doing!
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	hardware_id = "[SSnetworks.get_next_HID()]"
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src
	regestered_scokets = list()

	if(network_tag)
		SSnetworks.network_tag_to_hardware_id[network_tag] = hardware_id
		src.network_tag = network_tag
		to_chat(world,"New Interface [hardware_id] with tage [network_tag]")
	if(network_name)
		join_network(network_name)


/datum/component/ntnet_interface/proc/debug_port(port)
	var/list/debug_out = list()
	for(var/name in regestered_scokets[port])
		debug_out += "[name] = [regestered_scokets[port][name]]"
	debug_world_log("DEBUG_PORT: [debug_out.Join()]")

// this creates a virtual connection to the device.  The user
// can tell if the data has been updated by a latter timestamp and if the
// list is missing the timestamp
/datum/component/ntnet_interface/proc/connect_port(port)
	if(regestered_scokets[port])
		var/datum/netlink/link = regestered_scokets[port]
		link.connections++
		return link

// just for a consitant interface
/datum/component/ntnet_interface/proc/disconnect_port(datum/netlink/link)
	if(regestered_scokets[link.port]) // should I runtime if this isn't in here?
		link.connections--

/datum/component/ntnet_interface/proc/regester_port(port, list/data)
	if(!port || !length(data))
		log_runtime("port is null or data is empty")
		return
	if(regestered_scokets[port])
		log_runtime("port already regestered")
		return
	var/datum/netlink/link = new(data)
	link.server_id = hardware_id
	link.server_network = network.network_id
	link.port = port
	regestered_scokets[port] = link

/datum/component/ntnet_interface/Destroy()
	if(isatom(parent))
		UnregisterFromParent(parent, COMSIG_AREA_ENTERED)
	if(network)
		leave_network()
	if(network_tag)
		SSnetworks.network_tag_to_hardware_id.Remove(network_tag)
		network_tag = null
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	network = null
	for(var/port in regestered_scokets)
		regestered_scokets[port]["connected"] = FALSE // just in case of any open connections
	regestered_scokets = null
	return ..()

/datum/component/ntnet_interface/proc/join_network(network_name)
	if(network)
		leave_network()
	network = SSnetworks.find_network(network_name)
	if(network)
		network.interface_connect(src)

/datum/component/ntnet_interface/proc/leave_network()
	if(network)
		network.interface_disconnect(src)

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	set waitfor = FALSE
	if(!network)
		return
	if(length(regestered_scokets))
		var/service = regestered_scokets[data.port]
		if(islist(service))
			// if we are a list, this is a static return (like static data about the device)
			// Just make a new packet and return the list
			data.make_return(service)
			__network_send(data)
		// ok figure out how to detect a call.  do we want to use datum/callback?
	else
		parent.ntnet_receive(data)


/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data)			//Do not directly proccall!
	set waitfor = FALSE
	if(network)
		network.process_data_transmit(src, data)


