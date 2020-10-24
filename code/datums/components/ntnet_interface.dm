
/**
  * Helper function that does 90% of the work in sending a packet
  *
  * This function gets the component and builds a packet so the sending
  * person doesn't have to lift a finger.  Just create a netdata datum or even
  * just a list and it will send it on its merry way.
  *
  * Arguments:
  * * packet_data - Either a list() or a /datum/netdata.  If its netdata, the other args are ignored
  * * target_id - 	Target hardware id or network_id for this packet. If we are a network id, then its
					broadcasted to that network.
  * * passkey - 	Authentication for the packet.  If the target doesn't authenticate the packet is dropped
  */
/datum/proc/ntnet_send(packet_data, target_id = null, passkey = null)
	var/datum/netdata/data = packet_data
	if(!data) // check for easy case
		if(!islist(packet_data) || target_id == null)
			stack_trace("ntnet_send: Bad packet creation") // hard fail as its runtime fault
			return
		data = new(packet_data)
		data.receiver_id = target_id
		data.passkey = passkey
	if(data.receiver_id == null)
		return NETWORK_ERROR_BAD_TARGET_ID
	data.sender_id = NIC.hardware_id
	data.network_id = NIC.network.network_id

	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return NETWORK_ERROR_NOT_ON_NETWORK
	return SSnetworks.transmit(data)


/datum/component/ntnet_interface
	var/hardware_id = null				// text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null  					// named tag for looking up on mapping objects
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/registered_sockets = list()// list of ports opened up on devices
	var/list/alias = list() 			// if we live in more than one network branch

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


	network = SSnetworks.create_network_simple(network_name)
	network.add_interface(src)


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
