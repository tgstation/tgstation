/datum/proc/ntnet_receive(datum/netdata/data)
	return

/datum/proc/ntnet_receive_broadcast(datum/netdata/data)
	return

/datum/proc/ntnet_send(datum/netdata/data, netid)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data, netid)

/datum/component/ntnet_interface
	var/hardware_id						//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/datum/ntnet/network = null		// network we are on, we MUST be on a network or there is no point in this component
	var/list/regestered_scokets 		// list of call procs

/datum/component/ntnet_interface/Initialize(network_name=null)			//Don't force ID unless you know what you're doing!
	set_network(network_name)

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	linked_interfaces = null
	return ..()

/datum/component/ntnet_interface/proc/set_network(network_name=null)
	linked_interfaces = list() // clear linked names
	if(network)
		SSnetworks.unregister_interface(src)
	SSnetworks.register_interface(src, network_name)

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	if(!SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_RECEIVE, data))
		return
	if(differentiate_broadcast && data.broadcast)
		parent.ntnet_receive_broadcast(data)
	else
		parent.ntnet_receive(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!
	network.process_data_transmit(src, data)
	return TRUE

