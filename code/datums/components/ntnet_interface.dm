/datum/proc/ntnet_receive(datum/netdata/data)
	return


/datum/proc/ntnet_send(datum/netdata/data)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data)

/datum/component/ntnet_interface
	var/hardware_id						//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/regestered_scokets 		// list of call procs

/datum/component/ntnet_interface/Initialize(network_name)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src
	regestered_scokets = list() 
	if(network_name)
		join_network(network_name)

/datum/component/ntnet_interface/Destroy()
	if(network)
		network.interface_disconnect(src)
	SSnetworks.interfaces_by_hardware_id.Remove(hardware_id)
	network = null
	regestered_scokets = null
	return ..()

/datum/component/ntnet_interface/proc/join_network(network_name)
	if(network)
		network.interface_disconnect(src)
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


