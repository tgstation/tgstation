//Thing meant for allowing datums and objects to access an NTnet network datum.
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
	var/hardware_id			//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/datum/ntnet/network = null
	var/differentiate_broadcast = TRUE				//If false, broadcasts go to ntnet_receive. NOT RECOMMENDED.

/datum/component/ntnet_interface/Initialize(network_name=null)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	SSnetworks.register_interface(src, network_name)	// default to station

/datum/component/ntnet_interface/Destroy()
	SSnetworks.unregister_interface(src)
	return ..()

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_RECEIVE, data)
	if(differentiate_broadcast && data.broadcast)
		parent.ntnet_receive_broadcast(data)
	else
		parent.ntnet_receive(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!
	network.process_data_transmit(src, data)
	return TRUE

