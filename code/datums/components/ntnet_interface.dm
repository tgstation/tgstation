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
	var/list/regestered_scokets 		// list of call procs

/datum/component/ntnet_interface/Initialize(network_name,network_tag)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src
	regestered_scokets = list()
	if(network_tag)
		SSnetworks.network_tag_to_hardware_id[network_tag] = hardware_id
		src.network_tag = network_tag
	if(network_name)
		join_network(network_name)
	if(isatom(parent))
		var/atom/o = parent
		var/list/info = list("type" = o.type, "name" = o.name, "area" = get_area(o), "network_id" = network_name)
		RegisterSignal(parent, COMSIG_AREA_ENTERED, .proc/_area_change)
		if(src.network_tag)
			info["netowrk_tag"] = src.network_tag
		regester_port("info", info)

/datum/component/ntnet_interface/proc/regester_port(port, list/data)
	if(!port || !length(data))
		log_runtime("port is null or data is empty")
		return
	regestered_scokets[port] = data

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
	regestered_scokets = null
	return ..()

/datum/component/ntnet_interface/proc/_area_change(atom/M)
	var/list/info = regestered_scokets["info"]
	if(info)
		info["area"] = get_area(M)

/datum/component/ntnet_interface/proc/join_network(network_name)
	if(network)
		leave_network()
	network = SSnetworks.find_network(network_name)
	if(network)
		network.interface_connect(src)
		var/list/info = regestered_scokets["info"]
		if(info)
			info["network_id"] = network.network_id

/datum/component/ntnet_interface/proc/leave_network()
	if(network)
		network.interface_disconnect(src)
		var/list/info = regestered_scokets["info"]
		if(info)
			info.Remove("network_id")

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	set waitfor = FALSE
	if(!network)
		return
	if(length(regestered_scokets))
		var/service = regestered_scokets[data.receiver_port]
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


