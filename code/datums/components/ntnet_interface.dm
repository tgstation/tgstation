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

/datum/component/ntnet_interface/Initialize(network_name, network_root=null)			//Don't force ID unless you know what you're doing!
	set_network(network_name, network_root)

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	return ..()

/datum/component/ntnet_interface/proc/set_network(network_name, network_root=null)
	if(network)
		SSnetworks.unregister_interface(src)
	SSnetworks.register_interface(src, network_name, network_root)

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	set waitfor = FALSE
	var/service = regestered_scokets[data.receiver_port]
	if(service)
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
	network.process_data_transmit(src, data)


