/datum/proc/ntnet_receive(datum/netdata/data)
	SEND_SIGNAL(src, COMSIG_COMPONENT_NTNET_RECEIVE, data)


// helper function.  So you don't have to get the component
/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	data.sender_id = NIC.hardware_id
	data.network_id = NIC.network.network_id
	return SSnetworks.transmit(data)


/datum/component/ntnet_interface
	var/hardware_id = null				// text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null  					// named tag for looking up on mapping objects
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/registered_sockets = null	// list of ports opened up on devices
	var/list/network_alias = list() 		// if we live in more than one network branch TODO

/datum/component/ntnet_interface/Initialize(network_name, network_tag = null)
	if(!network_name)
		stack_trace("Bad network '[network_name]' for '[parent]', going to limbo it")
		network_name = NETWORK_LIMBO

	if(network_tag != null && text2num(network_tag) == text2num(num2text(network_tag)))
		// numbers are not allowed as lookups for interfaces
		stack_trace("Tag cannot be a number?  '[network_name]' for '[parent]', going to limbo it")
		network_tag = "BADTAG_" + network_tag

	hardware_id = "[SSnetworks.get_next_HID()]"
	id_tag = network_tag
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src
	registered_sockets = list()

	join_network(network_name)


// Port connection system
// The basic idea is that two or more objects share a list and transfer data between the list
// The list keeps a flag called "_updated", if that flag is set to "true" then something was
// changed.  Now I COULD send a signal, but that would require the parent object to be shoved
// in datum/netlink.  I am trying my best to not have hard references in any of these data
// objects
/datum/component/ntnet_interface/proc/connect_port(hid_or_tag, port, mob/user=null)
	ASSERT(hid_or_tag && port)
	var/datum/component/ntnet_interface/target = network.root_devices[hid_or_tag]
	if(target && target.registered_sockets[port])
		var/list/datalink = target.registered_sockets[port]
		return datalink
	if(user)
		to_chat(user,"Port [port] does not exist on [hid_or_tag]!")


/datum/component/ntnet_interface/proc/deregister_port(port)
	if(registered_sockets[port]) // should I runtime if this isn't in here?
		var/list/datalink = registered_sockets[port]
		NETWORK_PORT_DISCONNECT(datalink)
		// this should remove all outstanding ports
		registered_sockets.Remove(port)


/datum/component/ntnet_interface/proc/register_port(port, list/data)
	if(!port || !length(data))
		log_runtime("port is null or data is empty")
		return
	if(registered_sockets[port])
		log_runtime("port already regestered")
		return
	data["_updated"] = FALSE
	registered_sockets[port] = data

/datum/component/ntnet_interface/Destroy()
	leave_network(TRUE)
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	for(var/port in registered_sockets)
		deregister_port(port)
	registered_sockets.Cut()
	return ..()

/datum/component/ntnet_interface/proc/leave_network(clear_alias=FALSE)
	var/datum/ntnet/net
	if(network)
		network.linked_devices.Remove(hardware_id)
		network.root_devices.Remove(hardware_id)
		if(id_tag)
			network.root_devices.Remove(id_tag)
		if(network_alias.len)
			for(var/NA in network_alias)
				net = network.networks[NA]
				net.linked_devices.Remove(hardware_id)
			if(clear_alias)
				network_alias.Cut()
		network = null
/// Joins an existing network
/datum/component/ntnet_interface/proc/join_network(network_name)
	var/datum/ntnet/net
	if(network)
		leave_network()

	// remember we MUST have a network so don't leave without joining
	network = SSnetworks.create_network_simple(network_name)
	if(!network) // we crash here because there should be no way this can be null unless someone fucked up
		CRASH("Network '[network_name]' could not be created")
	network.linked_devices[hardware_id] = src
	network.root_devices[hardware_id] = src
	if(id_tag)
		// if we have an id_tag only put it in root_devices.
		if(network.root_devices[id_tag])
			stack_trace("Device tried to join the network with an existing tag '[id_tag]' [parent]")
			id_tag = null // tag is hard cleared so we can continue
		else
			network.root_devices[id_tag] = src

	// Add the network alias back up
	for(var/NA in network_alias)
		net = network.networks[NA]
		if(!net)
			network_alias.Remove(NA)
		else
			net.linked_devices[hardware_id] = TRUE

/// This is used if you want to add the interface over to other branches to broadcast
/// in like areas, ships etc
/datum/component/ntnet_interface/proc/add_alias(alias_id, replace_with = null)
	var/datum/ntnet/net
	if(replace_with && network_alias[replace_with]) // make sure it exists
		net = network.networks[replace_with]
		net.linked_devices.Remove(hardware_id)
		network_alias.Remove(hardware_id)

	if(alias_id && !network_alias[alias_id])
		net = network.networks[alias_id]
		net.linked_devices[hardware_id] = TRUE
		network_alias[hardware_id] = TRUE
