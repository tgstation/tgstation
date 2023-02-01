
/*
 * Helper function that does 90% of the work in sending a packet
 *
 * This function gets the component and builds a packet so the sending
 * person doesn't have to lift a finger.  Just create a netdata datum or even
 * just a list and it will send it on its merry way.
 *
 * Arguments:
 * * packet_data - Either a list() or a /datum/netdata.  If its netdata, the other args are ignored
 * * target_id - Target hardware id or network_id for this packet. If we are a network id, then its
					broadcasted to that network.
 * * passkey - Authentication for the packet.  If the target doesn't authenticate the packet is dropped
 */
/datum/proc/ntnet_send(packet_data, target_id = null, passkey = null)
	var/datum/netdata/data = packet_data
	if(!istype(data)) // construct netdata from list()
		if(!islist(packet_data))
			stack_trace("ntnet_send: Bad packet creation") // hard fail as its runtime fault
			return
		data = new(packet_data)
		data.receiver_id = target_id
		data.passkey = passkey
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return NETWORK_ERROR_NOT_ON_NETWORK
	data.sender_id = NIC.hardware_id
	data.network_id = NIC.network.network_id
	data.receiver_id ||= data.network_id
	return SSnetworks.transmit(data)

/*
 * # /datum/component/ntnet_interface
 *
 * This component connects a obj/datum to the station network.
 *
 * Anything can be connected to the station network.  Any obj can auto connect as long as its network_id
 * var is set before the parent new is called.  This allows map objects to be connected.  Technically the
 * component only handles getting you on the network while SSnetwork and datum/ntnet does all the real work.
 * There are quite a few stack_traces in here.  This is because error checking should be done before this component is
 * added.  Also, there never should be a component that has no network.  If it needs a network assign it to LIMBO
 *
 */
/datum/component/ntnet_interface
	var/hardware_id = null // text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null // named tag, mainly used to look up mapping objects
	var/datum/ntnet/network = null // network we are on, we MUST be on a network or there is no point in this component
	var/list/registered_sockets = list()// list of ports opened up on devices
	var/list/alias = list() // if we live in more than one network branch

/**
 * Initialize for the interface
 *
 * Assigns a hardware id and gets your object onto the network
 *
 * Arguments:
 * * network_name - Fully qualified network id of the network we are joining
 * * network_tag - The objects id_tag.  Used for finding the device at mapload time
 */
/datum/component/ntnet_interface/Initialize(network_name, network_tag = null)
	if(network_name == null || !istext(network_name))
		log_telecomms("ntnet_interface/Initialize: Bad network '[network_name]' for '[parent]', going to limbo it")
		network_name = LIMBO_NETWORK_ROOT
	// Tags cannot be numbers and must be unique over the world
	if(network_tag != null && !istext(network_tag))
		// numbers are not allowed as lookups for interfaces
		log_telecomms("Tag cannot be a number?  '[network_name]' for '[parent]', going to limbo it")
		network_tag = "BADTAG_" + network_tag

	hardware_id = SSnetworks.get_next_HID()
	id_tag = network_tag
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src

	network = SSnetworks.create_network_simple(network_name)

	network.add_interface(src)


/**
 * Create a port for this interface
 *
 * A port is basicity a shared associated list() with some values that
 * indicated its been updated.  (see _DEFINES/network.dm).  By using a shared
 * we don't have to worry about qdeling this object if it goes out of scope.
 *
 * Once a port is created any number of devices can use the port, however only
 * the creating interface can disconnect it.
 *
 * Arguments:
 * * port - text, Name of the port installed on this interface
 * * data - list, shared list of data.  Don't put objects in this
 */
/datum/component/ntnet_interface/proc/register_port(port, list/data)
	if(!port || !length(data))
		stack_trace("port is null or data is empty")
		return
	if(registered_sockets[port])
		stack_trace("port already regestered")
		return
	data["_updated"] = FALSE
	registered_sockets[port] = data

/**
 * Disconnects an existing port in the interface
 *
 * Removes a port from this interface and marks it that its
 * has been disconnected
 *
 * Arguments:
 * * port - text, Name of the port installed on this interface
 * * data - list, shared list of data.  Don't put objects in this
 */
/datum/component/ntnet_interface/proc/deregister_port(port)
	if(registered_sockets[port]) // should I runtime if this isn't in here?
		var/list/datalink = registered_sockets[port]
		NETWORK_PORT_DISCONNECT(datalink)
		// this should remove all outstanding ports
		registered_sockets.Remove(port)


/**
 * Connect to a port on this interface
 *
 * Returns the shared list that this interface uses to send
 * data though a port.
 *
 * Arguments:
 * * port - text, Name of the port installed on this interface
 */
/datum/component/ntnet_interface/proc/connect_port(port)
	return registered_sockets[port]

/datum/component/ntnet_interface/Destroy()
	network.remove_interface(src, TRUE)
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	for(var/port in registered_sockets)
		var/list/datalink = registered_sockets[port]
		NETWORK_PORT_DISCONNECT(datalink)
	registered_sockets.Cut()
	return ..()
