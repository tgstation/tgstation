/datum/proc/ntnet_receive(datum/netdata/data)
	return


/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	data.sender_id = NIC.hardware_id
	return NIC.network.process_data_transmit(data)

/datum/proc/ntnet_join_network(network_name, network_tag=null)
	if(!SSnetworks.verify_network_name(network_name))
		return FALSE
	return AddComponent(/datum/component/ntnet_interface, network_name, network_tag)


/datum/component/ntnet_interface
	var/hardware_id						//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null  			// named tag for looking up on mapping objects
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/regestered_scokets 		// list of connections

/datum/component/ntnet_interface/Initialize(network_name, network_tag=null)
	if(!network_name)
		to_chat(world, "Bad network name [network_name], going to limbo it")
		network_name = NETWORK_LIMBO

	src.hardware_id = "[SSnetworks.get_next_HID()]"
	src.id_tag = network_tag
	SSnetworks.interfaces_by_hardware_id[src.hardware_id] = src
	src.regestered_scokets = list()

	if(isatom(parent))
		var/atom/A = parent
		A.hardware_id = src.hardware_id
	join_network(network_name)
// Port connection system
// The basic idea is that two or more objects share a list and transfer data between the list
// The list keeps a flag called "_updated", if that flag is set to "true" then something was
// changed.  Now I COULD send a signal, but that would require the parent object to be shoved
// in datum/netlink.  I am trying my best to not have hard references in any of these data
// objects

// this creates a virtual connection to the device.  The user
// can tell if the data has been updated by a latter timestamp and if the
// list is missing the timestamp
/datum/component/ntnet_interface/proc/connect_port(port)
	if(regestered_scokets[port])
		// Make a copy, it wil get rid of data once the component is removed
		// So now you can qdel it like anything else
		var/datum/netlink/original = regestered_scokets[link.port]
		return new/datum/netlink/new(src, regestered_scokets[port].data)

// just for a consitant interface
/datum/component/ntnet_interface/proc/unregester_port(port)
	if(regestered_scokets[link.port]) // should I runtime if this isn't in here?
		var/datum/netlink/original = regestered_scokets[port]
		SEND_SIGNAL(src, COMSIG_COMPONENT_NTNET_PORT_DESTROYED, port, original.data)
		regestered_scokets.Remove(port)
		qdel(original)

/datum/component/ntnet_interface/proc/regester_port(port, list/data)
	if(!port || !length(data))
		log_runtime("port is null or data is empty")
		return
	if(regestered_scokets[port])
		log_runtime("port already regestered")
		return
	var/datum/netlink/original = new(src, data)
	link.server_id = hardware_id
	link.server_network = network.network_id
	link.port = port
	regestered_scokets[port] = original
	return original

/datum/component/ntnet_interface/Destroy()
	if(network)
		leave_network()
	if(isatom(parent))
		var/atom/A = parent
		A.hardware_id = null
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	for(var/port in regestered_scokets)
		unregester_port(port)
		qdel(regestered_scokets[port])  // hummm
	regestered_scokets = null
	return ..()

/datum/component/ntnet_interface/proc/join_network(network_name)
	if(network)
		leave_network()
	network = SSnetworks.create_network_simple(network_name)
	if(network)
		network.interface_connect(src)
		if(isatom(parent))
			var/atom/A = parent
			A.network_id = 	network.network_id
		// So why here?  Before this there were hacks (radio, ref sharing, etc) on how other objects "connected" with another
		// (embedded_controller, assembly's, etc).  They all had their own interfaces and snowflake connections.  By giving
		// everything a hardware_id and a network_id, now you can find and connect devices.  However, the problem is when maps
		// are loading, as of 9/25/2020, atmosinit() and a few other procs run BEFORE even Initialize()  (see. the state hack
		// hell that is the atoms init process)
		// Because maps are loaded though an async process AND Initialize/LateInitialize is only run per template and not when ALL maps are loaded there is no
		// no way for an atom to know if a device exists at map time.  Could try to change LateInitialize to run at the end of the map process but since it
		// doesn't pass mapload and itself is async, thats problematic.
		// You might say this shouldn't matter as of right now, each map should be isolated.  But if we ever start making
		// stations that contain multiple map templates or, for example, headset relays are converted to this system, something
		// needs to run after all the machines are down, all the maps are loaded, but no players exist yet.
		// So yea.  This is why we have to delay load
		if(!SSmapping.initialized)
			SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_JOIN_NETWORK, network)
		else
			SSnetworks.network_initialize_queue += src

/datum/component/ntnet_interface/proc/leave_network()
	if(network)
		network.interface_disconnect(src)
	if(isatom(parent))
		var/atom/A = parent
		A.network_id = 	null

