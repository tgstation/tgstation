/datum/proc/ntnet_receive(datum/netdata/data)
	return

// Must do this to make sure you have access
/obj/ntnet_receive(datum/netdata/data)
	SHOULD_CALL_PARENT(1)
	return !data.passkey || check_access_ntnet(data)

// moved here because it makes more sense.
/obj/proc/check_access_ntnet(datum/netdata/data)
	return check_access_list(data.passkey)
	

// helper function.  So you don't have to get the component
/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	data.sender_id = NIC.hardware_id
	data.network_id = NIC.network.network_id
	return SSnetworks.transmit(data)



/datum/component/ntnet_interface
	var/hardware_id = null				//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null  					// named tag for looking up on mapping objects
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/registered_sockets = null	// list of connections
	var/list/network_alias = null 		// if we live in more than one network branch TODO

/datum/component/ntnet_interface/Initialize(network_name, network_tag  =null)
	if(!network_name)
		ASSERT(network_name)
		to_chat(world, "Bad network '[network_name]' for '[parent]', going to limbo it")
		network_name = NETWORK_LIMBO
	if(network_tag != null && text2num(network_tag) == text2num(num2text(network_tag)))
		to_chat(world,"Tag is a number?  '[network_name]' for '[parent]', going to limbo it")
		ASSERT(!isnum(text2num(network_tag)))
	src.hardware_id = "[SSnetworks.get_next_HID()]"
	src.id_tag = network_tag
	SSnetworks.interfaces_by_hardware_id[src.hardware_id] = src
	src.registered_sockets = list()

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
	if(network)
		leave_network()
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	for(var/port in registered_sockets)
		deregister_port(port)
	registered_sockets = null
	return ..()

/datum/component/ntnet_interface/proc/join_network(network_name, list/extra = null)
	if(network)
		leave_network()
	var/datum/ntnet/net = SSnetworks.create_network_simple(network_name)
	ASSERT(net)
	net.interface_connect(src,extra)
	ASSERT(network)


/datum/component/ntnet_interface/proc/leave_network()
	if(network)
		network.interface_disconnect(src)
