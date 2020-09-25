/datum/proc/ntnet_receive(datum/netdata/data)
	return


/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data)

/datum/proc/ntnet_join_network(network_id, network_tag=null)
	if(network_id)
		AddComponent(/datum/component/ntnet_interface, network_id, network_tag)


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

	SSnetworks.interfaces_by_hardware_id[src.hardware_id] = src
	src.regestered_scokets = list()
	if(network_tag)
		src.id_tag = network_tag
		SSnetworks.network_tag_to_hardware_id[network_tag] = hardware_id
		to_chat(world,"New Interface [hardware_id] with tag [network_tag]")

	if(isatom(parent))
		var/atom/A = parent
		A.hardware_id = src.hardware_id
	join_network(network_name)




// this creates a virtual connection to the device.  The user
// can tell if the data has been updated by a latter timestamp and if the
// list is missing the timestamp
/datum/component/ntnet_interface/proc/connect_port(port)
	if(regestered_scokets[port])
		var/datum/netlink/link = regestered_scokets[port]
		link.connections++
		return link

// just for a consitant interface
/datum/component/ntnet_interface/proc/unregester_port(datum/netlink/link)
	if(regestered_scokets[link.port]) // should I runtime if this isn't in here?
		regestered_scokets.Remove(link.port)
		qdel(link)

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
	if(network)
		leave_network()
	if(isatom(parent))
		var/atom/A = parent
		A.hardware_id = null
	if(id_tag)
		SSnetworks.network_tag_to_hardware_id.Remove(network_tag)
		network_tag = null
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	for(var/port in regestered_scokets)
		qdel(regestered_scokets[port])  // hummm
	regestered_scokets = null
	return ..()

/datum/component/ntnet_interface/proc/join_network(network_name)
	if(network)
		leave_network()
	network = SSnetworks.find_network(network_name)
	if(network)
		network.interface_connect(src)
		if(isatom(parent))
			var/atom/A = parent
			A.network_id = 	network.network_id
		// So why here?  Before this there were hacks (radio, ref sharing, etc) on how other objects "connected" with another
		// (embedded_controller, assembly's, etc).  They all had their own interfaces and snowflake connections.  By giving
		// everything a hardware_id and a network_id, now you can find and connect devices.  However, the problem is when maps
		// are loading.  As of 9/25/2020, atmosinit() and a few other procs run BEFORE even Initialize() during map loading (see.
		// the state hell that is the atoms init process)
		// Because maps are loaded async AND Initialize is only run per template and not when ALL maps are loaded there is no
		// no way for an atom to know if a device exists at map time.
		// You might say this shouldn't matter as of right now, each map should be isolated.  But if we ever start making
		// stations that contain multiple map templates or, for example, headset relays are converted to this system, something
		// needs to run after all the machines are down, all the maps are loaded, but no players exist yet.
		// So yea.  This is why we have to delay load
		if(!SSmapping.initialized)
			SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_JOIN_NETWORK, network)
		else
			SSnetworks.init_interface_queue += src

/datum/component/ntnet_interface/proc/leave_network()
	if(network)
		network.interface_disconnect(src)
	if(isatom(parent))
		var/atom/A = parent
		A.network_id = 	null

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


